# this is for the sweeper of articles
#
# 1.
# write a module before the ArticleSweeperFor*Something*
# which contain after_save and after_destroy methods,
# and the two methods end with a *super*
#
# 2.
# add 'include ArticleSweeperFor*Something*' before the sign
#

module Sweepers

  module ArticleSweeperForTouzibao
  def after_save(entry)
    ids = ArticleTouzibao.where(:article_id => entry.id).select(:touzibao_id).map(&:touzibao_id)
    if ids.present?
      expire_cache_object("touzibao", "today")
      expire_cache_object("touzibao", "latest")
      ids.each do |id|
        expire_cache_object("touzibao", id)
      end
    end
    super
  end

  def after_destroy(entry)
        ids = ArticleTouzibao.where(:article_id => entry.id).select(:touzibao_id).map(&:touzibao_id)
    if ids.present?
      expire_cache_object("touzibao", "today")
      expire_cache_object("touzibao", "latest")
      ids.each do |id|
        expire_cache_object("touzibao", id)
      end
    end
    super
  end
  end
  
  module ArticleSweeperForPushArticle
    def before_save(entry)
      last_id = Article.last_important_article_id.value.try(:to_i)
      if entry.id and entry.need_push_changed? and last_id
        if entry.need_push == 1 and last_id < entry.id
          Article.last_important_article_id = entry.id  
          Rails.cache.delete(Article::IMPORTANT_ARTICLE_CACHE_KEY)
        elsif last_id == entry.id and entry.need_push == 0
          Article.last_important_article_id.del
          Rails.cache.delete(Article::IMPORTANT_ARTICLE_CACHE_KEY)
        end
      elsif entry.id and entry.id == last_id
        Rails.cache.delete(Article::IMPORTANT_ARTICLE_CACHE_KEY)
      end
    end

    def after_destroy(entry)
      if entry.need_push == 1
        Article.last_important_article_id.del
        Rails.cache.delete(Article::IMPORTANT_ARTICLE_CACHE_KEY)
      end      
      super
    end
  end

  module ArticleSweeperForColumnist
    def after_save(entry)
      columnist_ids = ArticlesColumnist.where(:article_id => entry.id).map(&:columnist_id)
      Columnist.update(columnist_ids, Array.new(columnist_ids.count){ {:updated_at => Time.now} })
      if columnist_ids.present?
        expire_cache_object("columnist", "index_table")
        columnist_ids.each do |id|
          expire_cache_object("columnist", id)
        end
      end
      super
    end

    def after_destroy(entry)
      columnist_ids = ArticlesColumnist.where(:article_id => entry.id).map(&:columnist_id)
      Columnist.update(columnist_ids, Array.new(columnist_ids.count){ {:updated_at => Time.now} })
      if columnist_ids.present?
        expire_cache_object("columnist", "index_table")
        columnist_ids.each do |id|
          expire_cache_object("columnist", id)
        end
      end
      super
    end
  end

  module ArticleSweeperForStaffRecord
    def after_save(entry)
      Rails.logger.info "###########  create record for staff's manner  #############"
      Rails.logger.info "--------------------current_staff: #{current_staff.inspect}"
      Rails.logger.info "--------------------request.remote_ip #{request.remote_ip.inspect}"
      if entry.status_changed? and entry.status == Article::BANNDED
        entry.article_logs.create(:staff_id => current_staff.id, :article_title => entry.title, :cmd => ArticleLog::BAN, :remote_ip => request.remote_ip)
      #elsif entry.status_changed? and entry.status == Article::PUBLISHED
        #entry.article_logs.create(:staff_id => current_staff.id, :article_title => entry.title, :cmd => ArticleLog::PUBLISH, :remote_ip => request.remote_ip)
      #else
        #entry.article_logs.create(:staff_id => current_staff.id, :article_title => entry.title, :cmd => ArticleLog::UPDATE, :remote_ip => request.remote_ip)
      end
      super
    end

    def after_destroy(entry)
      Rails.logger.info "###########  create record for staff's manner  #############"
      entry.article_logs.create(:staff_id => current_staff.id, :article_title => entry.title, :cmd => ArticleLog::DELETE, :remote_ip => request.remote_ip)
      super
    end
  end

  module ArticleSweeperForChildrenArticles
    def after_save(entry)
      if !entry.id.nil? and (entry.title_changed? || entry.list_title_changed?)
        parent_article_ids = entry.relate_article_parent.map(&:article_id)
        parent_article_ids.each do |id|
          expire_cache_object("article", id)
        end
        column_ids = ArticlesColumn.where(:article_id => parent_article_ids).map(&:column_id)
        Column.update(column_ids, Array.new(column_ids.count){ {:updated_at => Time.now} })
        super
      end
    end

    def after_destroy(entry)
      parent_article_ids = entry.relate_article_parent.map(&:article_id)
      parent_article_ids.each do |id|
        expire_cache_object("article", id)
      end
      column_ids = ArticlesColumn.where(:article_id => parent_article_ids).map(&:column_id)
      Column.update(column_ids, Array.new(column_ids.count){ {:updated_at => Time.now} })
      super
    end
  end

  module ArticleSweeperForNewspaper
    def after_save(entry)
      if (news_id = entry.articles_newspaper.try(:newspaper_id))
        Rails.cache.delete(entry.newspaper.api_newspaper_cache_key) if entry.newspaper
        expire_cache_object("newspaper", news_id)
      end
    end

    def after_destroy(entry)
      if (news_id = entry.articles_newspaper.try(:newspaper_id))
        Rails.cache.delete(entry.newspaper.api_newspaper_cache_key) if entry.newspaper
        expire_cache_object("newspaper", news_id)
      end
    end
  end

  class ArticleSweeper < ActionController::Caching::Sweeper
    observe ::Article

    include ArticleSweeperForNewspaper
    include ArticleSweeperForChildrenArticles
    include ArticleSweeperForStaffRecord
    include ArticleSweeperForColumnist
    include ArticleSweeperForPushArticle
    include ArticleSweeperForTouzibao

    # include new module behinde this line

    def before_save(entry)
      super
    end

    def after_save(entry)
      if entry.is_rolling_news_changed?
        expire_cache_object("column", Column::ROLLING_COLUMN_ID)
      end
      Rails.cache.delete(entry.newspaper.api_newspaper_cache_key) if entry.newspaper
      expire_cache_object(entry)
      update_static_fragment_page(entry.id, entry.columns.map(&:id), entry.prev_column_ids)
      super 
    end


    def after_destroy(entry)
      if entry.is_rolling_news == 1
        expire_cache_object("column", Column::ROLLING_COLUMN_ID)
      end
      Rails.cache.delete(entry.newspaper.api_newspaper_cache_key) if entry.newspaper
      expire_cache_object(entry)
      update_static_fragment_page(entry.id, entry.columns.map(&:id), entry.prev_column_ids)
      super
    end

    private

    def update_static_fragment_page(article_id, column_ids, old_column_ids)
      old_column_ids ||= []
      update_column_ids = (old_column_ids | column_ids) & Column::FEATURE_COLUMN_HASH.values
      update_channel_ids = (old_column_ids | column_ids) & Column::COLUMN_PICTURE.values
      params = {:column_top_picks_pages => update_column_ids, :column_picture_articles => update_channel_ids, :hot_picture_articles => update_channel_ids}
      Resque.enqueue(Jobs::UpdateStaticFragmentPage, article_id, params)
    end
  end

end

