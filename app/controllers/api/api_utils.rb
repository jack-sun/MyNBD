#encoding:utf-8
module Api::ApiUtils
  DEFAULT_ARTICLES_PARAMS = {:count => 15, :page => 1, :since_id => -1, :max_id => -1}
  DEFAULT_LIVES_PARAMS = {:count => 10, :page => 1, :since_id => -1, :max_id => -1}
  DEFAULT_COLUMNISTS_PARAMS = {}
  def self.included(base)
    base.extend         ClassMethods
    base.class_eval do
      before_filter do
        Rails.logger.debug "--------------- #{base.to_s.underscore} "
      end
     case base.to_s.underscore.split("/").second.split("_").first
      when "articles", "columns"
        before_filter :init_articles_params
      when "lives"
        before_filter :init_lives_params
      when "columnists"
        before_filter :init_columnists_params
      end
    end
    base.send :include, InstanceMethods
  end # self.included

  module ClassMethods

  end # ClassMethods

  module InstanceMethods
    private
    def init_articles_params
      init_params(DEFAULT_ARTICLES_PARAMS)
    end

    def init_lives_params
      init_params(DEFAULT_LIVES_PARAMS)
    end

    def init_columnists_params
      init_params(DEFAULT_COLUMNISTS_PARAMS)
    end

    def init_params(default_params)
      Rails.logger.debug "--------------#{t}"
      @merged_params = default_params.merge(params.symbolize_keys).symbolize_keys
    end

    def articles_columns_filter(articles_columns)
      articles_columns = articles_columns.published.includes({:article => [:pages, :image, :articles_columns, :staffs]})
  
      return filter_by_page_attribute(articles_columns, "articles_columns", @merged_params, "pos")
    end

    def articles_filter(articles)
      articles = articles.includes([:pages, :image, :articles_columns, :staffs])

      return filter_by_page_attribute(articles, "articles", @merged_params)
    end

    def stock_lives_filter(live)
      #if Live::SHOW_ANSWER_IN_MOBILE
        #live_talks = live.live_talks.select([:id, :weibo_id, :talk_type]).to_a
        #live_talk_comment = live_talks.find_all{|t| t.talk_type == LiveTalk::TYPE_TALK }
        #live_talk_question = live_talks - live_talk_comment
        #live_answer_weibo_ids = LiveAnswer.where(:live_talk_id => live_talk_question.map(&:id)).select(:weibo_id).map(&:weibo_id)
        #weibos = Weibo.where(:id => (live_talk_comment.map(&:weibo_id) + live_answer_weibo_ids)).includes(:owner => :image)

      #else
        #weibo_ids = live.live_talks.comment.map(&:weibo_id)
        #weibos = Weibo.where(:id => weibo_ids).includes(:owner => :image)
      #end
      #@live_talks = @live.live_talks.comment.includes([:weibo => {:owner => :image}, :live_answers => {:weibo => {:owner => :image}}])
      @live_talks = @live.live_talks.comment.includes([:weibo => {:owner => :image}])
      return filter_by_page_attribute(@live_talks, "live_talks", @merged_params)
    end

    def stock_live_index_filter(lives)
      return filter_by_page_attribute(lives, nil, @merged_params)
    end

    def reverse(objects)
      if @merged_params[:since_id] != -1
        objects.reverse
      else
        objects
      end
    end

    private
    # type
    # 如果AR中的where上使用了 type.attribute 会报错
    # 可能是AR的错误 
    def filter_by_page_attribute(objects, type, params_hash, attribute = "id")
      order = ""
      if params_hash[:since_id] != -1
        order = "asc"
        if type
          objects = objects.where(["#{type}.#{attribute} > ?", params_hash[:since_id]])
        else
          objects = objects.where(["#{attribute} > ?", params_hash[:since_id]])
        end
      elsif params_hash[:max_id] != -1
        if type
          objects = objects.where(["#{type}.#{attribute} < ?", params_hash[:max_id]])
        else
          objects = objects.where(["#{attribute} < ?", params_hash[:max_id]])
        end
        order = "desc"
      else
        order = "desc"
      end
      objects = objects.page(params_hash[:page]).per(params_hash[:count]).order("#{attribute} #{order}")
      return objects
    end
  end # InstanceMethods

end
