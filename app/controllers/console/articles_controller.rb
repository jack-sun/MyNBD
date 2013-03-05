#encoding:utf-8
module Console
  class ArticlesController < ApplicationController
    layout "console"
    skip_before_filter :current_user
    before_filter :current_staff
    before_filter :authorize_staff
    before_filter :init_news_console, :except => [:stats, :top_stats]
    before_filter :init_common_console, :only => [:stats, :top_stats]
    
    cache_sweeper Sweepers::PageSweeper, Sweepers::ArticleSweeper, Sweepers::ColumnistSweeper, :only => [:destroy, :create, :update, :add_child_article, :remove_articles, :change_children_articles_pos, :change_status, :remove_child_article, :ban_by_ids]
    
    def published
      @articles = @current_staff.articles.published.includes({:columns => :parent}, :staffs, :pages, :children_articles, :weibo).order('id desc').page params[:page]
      @category = Article::PUBLISHED
      @sortable = false
      render :show
    end
    
    def draft
      @articles = @current_staff.articles.draft.includes({:columns => :parent}, :staffs, :pages, :children_articles, :weibo).order('id desc').page params[:page]
      @category = Article::DRAFT
      @sortable = false
      render :show
    end
    
    def banned
      @articles = @current_staff.articles.banned.includes({:columns => :parent}, :staffs, :pages, :children_articles, :weibo).order('id desc').page params[:page]
      @category = Article::BANNDED
      @sortable = false
      render :show
    end
    
    
    def new
      column = Column.where(:id => params[:column_id]).first
      @selected_id = column.nil? ? -1 : column.id
      @article = Article.new(:allow_comment => false, :is_rolling_news => true) 
      session[:article_jump] = request.env["HTTP_REFERER"]
    end
    
    def destroy
      @article = Article.find(params[:id])
      @article.columns.each do |c|
        c.updated_at = Time.now
        c.save!
      end
      columnists = @article.columnists.to_a
      @article.destroy
      columnists.each(&:update_last_article)
      redirect_to :back
    end
    
    def remove_articles
      articles = Article.where(:id => params[:article_ids].split(","))
      articles.each do|article|
        article.columns.each do |c|
          c.updated_at = Time.now
          c.save!
        end
        
        article.destroy
      end
      
      render :text => "done"
    end
    
    #TODO
    def index
      @articles = Article.published.includes({:columns => :parent}, :staffs, :pages, :children_articles, :weibo).order('pos asc').page params[:page]#@current_staff.articles.page params[:page]
      @category = ""
      @sortable = false
      render :show
    end

    def search_by_ids
      if params[:ids]
        @ids = params[:ids]
      else 
        @articles = []
        @ids = ""
      end
      @articles = Article.where(:id => @ids.split(",")).includes({:columns => :parent}, :staffs, :pages, :children_articles, :weibo).order('id desc').page(params[:page]).per(20)#@current_staff.articles.page params[:page]
      @category = ""
      @sortable = false
    end

    def ban_by_ids
      ids = params[:ids].split(",")
      if ids.blank?
        flash[:success] = "未找到相关文章"
        return render :search_by_ids
      end
      Article.update(ids, Array.new(ids.count){ {:status => Article::BANNDED} })
      ArticlesColumn.update_all(["status = ?", Article::BANNDED], :article_id => ids)
      flash[:success] = "文章#{ids.join(",")}屏蔽成功"
      @articles = Article.where(:id => "").page(0)
      @category = ""
      @sortable = false
      render :search_by_ids
    end
    
    def create
      #@article = @current_staff.articles.create((params[:article]))
      @article = @current_staff.create_article(params[:article])
      if @article.errors.size > 0
        column = Column.where(:id => params[:column_id]).first
        @selected_id = column.nil? ? -1 : column.id
        return render :action => :new
      end

      if session[:article_jump]
        redirect_path = session[:article_jump]
        session[:article_jump] = nil
        return redirect_to redirect_path
      end

      if params[:article][:status].to_i == 1
        if params[:from_column_id].blank?
        	redirect_to published_console_articles_path
        else
        	redirect_to console_column_url(params[:from_column_id])
        end
      else
        redirect_to draft_console_articles_path
      end
    end
    
    def edit
      @article = Article.find(params[:id])
      session[:article_jump] = request.env["HTTP_REFERER"]
    end
    
    def update
      @article = Article.find(params[:id])
      old_status = @article.status
      @article = @article.update_self(params[:article])
      if old_status == Article::BANNDED and @article.status == Article::PUBLISHED
        @article.article_logs.create(:staff_id => current_staff.id, :article_title => @article.title, :cmd => ArticleLog::PUBLISH, :remote_ip => request.remote_ip)
      else
        @article.article_logs.create(:staff_id => current_staff.id, :article_title => @article.title, :cmd => ArticleLog::UPDATE, :remote_ip => request.remote_ip)
      end

      Rails.logger.debug "----------------#{@article.errors.inspect}"
      if @article.errors.size > 0
        return render :action => :edit
      end

      if session[:article_jump]
        redirect_path = session[:article_jump]
        session[:article_jump] = nil
        return redirect_to redirect_path
      end
      
      if params[:article][:status].to_i == 1
         if params[:from_column_id].blank?
          redirect_to published_console_articles_path
        else
          redirect_to console_column_url(params[:from_column_id])
        end
      elsif params[:article][:status].to_i == 2
        redirect_to banned_console_articles_path
      elsif params[:article][:status].to_i == 0
        redirect_to banned_console_articles_path
      end
      
    end
    
    def change_pos
    end

    # AJAX： 更改文章状态
    def change_status
      @article = Article.find(params[:id])
      old_status = @article.status
      
      unless @article.update_attributes(:status => params[:status])
        return render :js => "alert('更改失败')"
      end
      if old_status == Article::BANNDED and @article.status == Article::PUBLISHED
        @article.article_logs.create(:staff_id => current_staff.id, :article_title => @article.title, :cmd => ArticleLog::PUBLISH, :remote_ip => request.remote_ip)
      else
        @article.article_logs.create(:staff_id => current_staff.id, :article_title => @article.title, :cmd => ArticleLog::UPDATE, :remote_ip => request.remote_ip)
      end
      @objects = [@article]
    end
    
    #AJAX
    def staff_articles
      @articles = @current_staff.articles.order("created_at DESC").page(0).per(20)
      
      render :text => render_to_string(:partial => "console/articles/staff_articles", :layout => false)
    end

    def dynamic_search
      @articles = Article.search(params[:q], :page => params[:page]||1, :per_page => params[:per], :order => :id, :sort_mode => :desc, :with => {:status => Article::PUBLISHED})
      render :text => render_to_string(:partial => "console/articles/staff_articles", :layout => false)
    end
    
    
    #AJAX
    def dynamic_articles
      @display_type = (params[:display_type] || ElementArticle::DISPLAY_TYPE_LIST).to_i 
      if params[:article_ids]
        @articles = Article.where(:id => params[:article_ids])
        return render :text => render_to_string(:partial => "console/articles/dynamic_articles", :layout => false)
      end
      @article_source = (params[:article_source] || ElementArticle::ARTICLE_SOURCE_COLUMN).to_i
      count = params[:count] = (params[:count] || 10).to_i
      count = params[:count] = (count > 50) ? 50 : count
      
      @articles = if @article_source == ElementArticle::ARTICLE_SOURCE_COLUMN # column articles
        ArticlesColumn.where(:column_id => params[:value], :status => Article::PUBLISHED).select([:article_id]).order("id DESC").includes(:article => {:pages => :image}).page(0).per(count)
      else # tag articles
        @articles = Article.search(:conditions => {:tags => params[:value].split(",").first}, :page => 1, :per_page => count, :order => :id, :sort_mode => :desc, :with => {:status => Article::PUBLISHED})
      end
      
      render :text => render_to_string(:partial => "console/articles/dynamic_articles", :layout => false)
    end

    def article_logs
      @article = Article.find(params[:id])
      @logs = @article.article_logs.includes(:staff)
    end

    #for realte articles
    #
    def manage_children_article
      Rails.logger.debug "-------------params[:from]: #{params[:from]}"
      @article = Article.find(params[:article_id])
      @children_articles = @article.relate_article_children.order("pos desc").includes(:children)
      @from = params[:from] = params[:from] || "mine" 
      Rails.logger.debug "-------------@from: #{@from}"
      if params[:from] == "column" && params[:column_id].size > 0
        column = Column.find(params[:column_id])
        if column.parent_id.nil?
          @root_column = column
          @current_column = @root_column.children.first
        else
          @current_column = column
          @root_column = @current_column.root
        end
        @articles = @current_column.articles_columns.includes(:article).order("pos DESC").page(params[:page]).per(15)
      elsif params[:from] == "mine" 
        Rails.logger.debug "--------------here"
        @articles = @current_staff.articles_staffs.includes(:article).order("id DESC").page(params[:page]).per(15)
        Rails.logger.debug "-----@articles: #{@articles.inspect}"
      elsif params[:from] == "search" and params[:q].present?
        @articles = Article.search(params[:q], :page => params[:page], :per_page => 15, :order => :id, :sort_mode => :desc)
      end
    end
    
    def add_child_article
      @children_article = if params[:id] and params[:child_id]
                            articles = Article.where(:id => [params[:id], params[:child_id]]).to_a.group_by(&:id)
                            articles[params[:id].to_i].first.add_child_article(articles[params[:child_id].to_i].first)
                          elsif params[:id] and params[:children_title] and params[:children_url]
                            article = Article.find(params[:id])
                            article.add_child_article(params.extract(*[:children_title, :children_url]))
                          end
      render :text => "faild" if @children_article == "faild"
    end
    
    def remove_child_article
      article = Article.find(params[:id])
      relate_child_article = ArticlesChildren.find(params[:child_id])
      article.remove_child_article(relate_child_article)
      render :text => "success"
    end
    
    def change_children_articles_pos
      current_article = Article.find(params[:id])
      moved_article = ArticlesChildren.find(params[:moved_id])
      target_article = ArticlesChildren.find(params[:target_id])
      render :text => current_article.change_children_articles_pos(moved_article, target_article)
    end

    def stats
      @common_navs = "stats"
      @stats_type = params[:type] || "staff"
      @filter_type = params[:filter] || "today"
      case @stats_type
      when "staff"
        @stats = Staff.common_editors.where(:status => 1).page(params[:page]).per(30)
        @record = ArticlesStaff.staffs_stats(@stats.map(&:id), @filter_type)
      when "column"
        @stats = Column.page(params[:page]).per(30)
        @record = ArticlesColumn.columns_stats(@stats.map(&:id), @filter_type)
      when "newspaper"
        @stats = Newspaper.time_filter(@filter_type).page(params[:page]).per(30).order("id desc")
        @record = ArticlesNewspaper.newspapers_stats(@stats.map(&:id), @filter_type)
      when "channel"
        @stats = Column.select([:id, :name, :parent_id]).where(:parent_id => nil)
        @record = ArticlesColumn.channel_stats(@filter_type)
      end
    end

    def top_stats
      @common_navs = "top_stats"
      @stats_type = params[:type] || "staff"
      @filter_type = params[:filter] || "today"
      @record = Article.time_filter(@filter_type).includes(:staffs).page(params[:page]).per(30).order("click_count desc")
    end

  end
end
