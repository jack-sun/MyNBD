# encoding: utf-8
module Console
  class ColumnsController < ConsoleBaseController
    layout 'console'
    skip_before_filter :current_user
    before_filter :current_staff
    before_filter :authorize_staff
    before_filter :init_news_console
    before_filter :init_common_console, :only => [:change_charge_staff]
    before_filter :init_common_console, :only => [:show], :if => lambda { |controller| 
      return true if params[:console] == 'common'
      return false
    }
    cache_sweeper Sweepers::PageSweeper

    after_filter :only => [:change_pos, :change_pos_to_first] do |c|
      column_id = @column.id
      params = {:column_top_picks_pages => [column_id]}

      params.merge({:column_picture_articles => [column_id], 
                    :hot_picture_articles => [column_id]}) if Column::COLUMN_PICTURE.values.include?(column_id)
      Resque.enqueue(Jobs::UpdateStaticFragmentPage, nil, params)
    end

    # def update_static_page
    # end

    def remove_articles
      @article_ids = params[:article_ids].split(",")
      @column = Column.find(params[:id])
      @column.update_attribute(:updated_at, Time.now)
      #@column.articles_columns.delete_all({:article_id => @article_ids})
      ArticlesColumn.delete_all(:column_id => @column.id, :article_id => @article_ids)
    end

    def show
      column = Column.find(params[:id])
      #return render :text => "你没有权限访问这个频道，请联系系统管理员开通相应权限" unless @current_staff.columns.includes(column)
      
      if column.parent_id.nil?
        @column = column
        @sub_columns = @column.children.console_displayable
        @current_column = @sub_columns.first
      else
      #  @column = Column.where(:id => column.parent_id).first
        @column = Column.find(column.parent_id)
        @sub_columns = @column.children.console_displayable
        @current_column = column
      end
      
      @articles_columns = @current_column.articles_columns.order("pos desc").includes({:article => [{:columns => :parent}, :staffs, :pages, :children_articles, :weibo]}).page params[:page]
      @sortable = true
    end

    def change_pos
      moved_article_id = params[:article_id].to_i
      target_article_id = params[:target_id].to_i
      @column = Column.find(params[:id])
      articles = Article.where(:id => [moved_article_id, target_article_id]).to_a.group_by(&:id)
      return render :text => "faild" if articles.count < 2
      moved_article = articles[moved_article_id].first
      target_article = articles[target_article_id].first
      text = @column.change_articles_pos(moved_article, target_article)
      render :text => text
    end

    def change_pos_to_first
      @column = Column.find(params[:id])
      moved_article = Article.find(params[:article_id])
      target_article_id = @column.articles_columns.order("pos desc").first.try(:article_id)
      if target_article_id
        text = @column.change_articles_pos(moved_article, target_article_id)
        return render :text => text
      end
      render :text => "faild"
    end

    def add_articles
      column = Column.find(params[:id])
      articles_ids = params[:article_ids].split(",")
      articles = Article.where(:id => articles_ids)
      return render :text => "success" unless articles
      render :text => column.add_articles(articles.to_a)
    end

    def fragment_cache_manage
      @fragment_mana_nvs = true
    end
      
    def expire_all_fragment
      Rails.logger.debug "expire_fragment of column #{params[:id]}"
      if params[:id]
        render :text => Rails.cache.delete_matched("views/column_#{params[:id]}*")
      else
        render :text => Rails.cache.delete_matched("views/*")
      end
    end
    
    def column_list
      @columns = Column.find(Column::DIS_MAIN_NAVS)
      
      render :text => render_to_string(:partial => "console/columns/column_list", :layout => false)
    end

    def change_charge_staff
      column = Column.find(params[:column])
      if column.update_attribute(:staff_id_in_charge, params[:charge_staff])
        flash[:notice] = "修改成功"
        redirect_to common_list_console_column_performance_logs_url
      end
    end

  end
end
