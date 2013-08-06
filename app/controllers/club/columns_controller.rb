class Club::ColumnsController < ApplicationController
    layout 'nbdclub'
    before_filter :forbid_request_of_mobile_news, :only => [:show]
    # after_filter :only => [:show, :index] do |c|
    #   path = nbd_page_cache_path
    #   write = nil
    #   if params[:page]
    #     write = params[:page].to_i < 11
    #   else
    #     write = true
    #   end
    #   if write and !File.exists?(path)
    #     Resque.enqueue(Jobs::WritePageCache, response.body, path)
    #     Resque.enqueue_in(Column::PAGE_CACHE_EXPIRE_TIME, Jobs::DeletePageCache, "column", path)
    #   end
    # end

    def index
         @head_articles = {:articles => Article.of_column(176, 3), :id => 176} #头条
         @kx_articles = {:articles => Article.of_column(177, 5), :id => 177} #快讯
         @pp_articles = {:articles => Article.of_column(178, 5), :id => 178} #品牌
         @sl_articles = {:articles => Article.of_column(179, 5), :id => 179} #沙龙
         @gy_articles = {:articles => Article.of_column(180, 5), :id => 180} #公益
         
      #栏目： club.nbd.com.cn    1. 头条（176）  2. 活动快讯（177）   3. 品牌活动（178）  4.每经沙龙（179）   5. 每经公益（180）   6. 每经讲堂（181）
    end

    def show
        @column_id = params[:id].to_i
        @column = Column.find(@column_id)
        @articles_columns = Article.of_child_column_for_ntt(@column_id).page(params[:page]).per(15)

        render :action => "articles_list"
        return
    end
end
