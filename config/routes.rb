Nbd::Application.routes.draw do

  get "test/test"
  
  get "specials/wishwall"
  get "specials/poll_details", :as => :poll_details
  
  get "search/article_search", :as => :article_search
  get "search/article_tag_search", :as => :article_tag_search
  get "search/community_search", :as => :community_search
  get "search/user_search", :as => :user_search
  get "search/image_search", :as => :image_search
 
  resources:mobiles, :only => [] do
    collection do
      get :android, :as => :android
      get :iphone, :as => :iphone
      get :ipad, :as => :ipad
    end
  end
  
  resources :weibos, :only => [] do
    member do
      get "rt"
      post "rt"
    end
    resources :comments, :only => [:index]
  end

  resources :polls, :only => [] do
    post :vote, :on => :member
    get :result, :on => :member
  end

  constraints :subdomain => CLUB_EXP do
    root :to => "club/columns#index", :as => :club_index
    namespace :club, :path => "" do
      resources :columns, :only => [:show, :index] do
      end
    end
  end

  constraints :subdomain => API_EXP do
    namespace :api, :path => "/:editon" do
      resources :touzibaos, :only => [] do
        collection do
          get :latest
          get :today
          get :plans
          get :terms
        end

        member do
          get :specify
        end
      end

      resource :user, :only =>[] do
        post :sign_in
        post :sign_out
        post "sign_up" => :create
        #get "sign_up"
        get "account"
        post "payment_notify"
        #get 'login'
        get 'log_out'
      end

      resources :columns, :only => [] do
        get :articles, :on => :member
      end
      resources :articles, :only => [:show] do
        get :rolling_news, :on => :collection
        get :pull_important_news, :on => :collection
      end
      resources :columnists, :only => [] do
        get :last_update, :on => :collection
        get :articles, :on => :member
      end
      resources :stock_lives, :controller => :lives, :l_type => Live::TYPE_STOCK, :only => [:show, :index] do
        get :today, :on => :collection
        member do
          get :fetch_new
          get :check_new
        end
      end
    end
  end

  constraints :subdomain => NTT_EXP do
    root :to => "ntt/columns#index", :as => :ntt_index
    match "about" => "ntt/columns#about"
    namespace :ntt, :path => "/" do
      resources :columns, :only => [:show, :index] do
        get "page/:page", :action => :show, :on => :member
        get "features", :on => :collection
      end
      resources :columnists, :only => [:show, :index]
      resources :articles, :only => [:show] do
        get "/:data/:id/page/:page_id" => :page, :on => :collection, :as => :page
        get "/:data/:id" => :show, :on => :collection
      end
    end
  end
  
  constraints :subdomain => WESTERN_EXP do
    root :to => "west/columns#index", :as => :west_index
    namespace :west, :path => "/" do
      resources :columns, :only => [:show, :index] do
        get "page/:page", :action => :show, :on => :member
      end
      resources :articles, :only => [:show] do
        get "/:data/:id/page/:page_id" => :page, :on => :collection, :as => :page
        get "/:data/:id" => :show, :on => :collection
      end
    end
  end

  resources :weibos , :only => [:create, :destroy] do
    resources :comments , :only => [:create, :destroy] do
      member do
        delete "ban"
      end
    end
    
    member do
      delete "ban"
    end
  end
  
  resources :authentications
  get '/auth/:provider/callback' => 'authentications#create' 
  match "mobile/index" => "mobile_server#index"
  
  constraints :subdomain => WWW_EXP do
    
    root :to => "columns#show", :id => 1, :as => "index"
    resources :columns, :only => [:show] do
      get "page/:page", :action => :show, :on => :member
    end

    namespace :premium do
      resources :mobile_news, :only => [] do
        collection do
          get :introduce
        end
      end
      resource :mobile_newspaper_account, :only => [:new, :show] do
        get :introduce
        post :subscribe
        post :activate
        get :success
        get :failed
        get :waiting
        get :faq
      end

      resources :touzibaos, :only => [:show] do
        collection do
          get :today
          get :yesterday
        end
      end

      resources :feedbacks, :only => [:create, :new] do
        collection do
          get :success
          get :alert
        end
      end

      resource :alipay, :only => [] do
        match "notify"
      end
    end
  
    resource :rss, :only => [:show] do
      get "/feed/:id" => :feed, :as => :feed
      get "/channel/:id" => :channel, :as => :channel
      get "newest" => :newest, :as => :newest
      get "stock_invest" => :stock_invest, :as => :stock_invest
      get "company" => :company, :as => :company
      get "finace" => :finace, :as => :finace
      get "daily_headline" => :daily_headline, :as => :daily_headline
      get "finace_headline" => :finace_headline, :as => :finace_headline
      get "infomation_headline" => :infomation_headline, :as => :infomation_headline
      get "manage" => :manage, :as => :manage
      get "finace_life" => :finace_life, :as => :finace_life
    end
    
    controller :general do
      get "/about" => :about, :as => :about
      get "/privacy" => :privacy, :as => :privacy
      get '/mobile_newspaper_privacy' => :mobile_newspaper_privacy, :as => :mobile_newspaper_privacy
      get "/copyright" => :copyright, :as => :copyright
      get "/copyright_2005" => :copyright_2005, :as => :copyright_2005
      get "/advertisement" => :advertisement, :as => :advertisement
      get "/contact" => :contact, :as => :contact
      get "/links" => :links, :as => :links
      get "/sitemap" => :sitemap, :as => :sitemap
      get "/disclaimer" => :disclaimer, :as => :disclaimer
    end
    
    resources :newspapers, :only => [:show] do
      get 'today', :on => :collection
    end

    resources :features, :only => [:show, :index] do
      get "page/:page_id" => :page, :on => :member, :as => :page
    end
    
    namespace "mobile" do
    	resources :columns, :only => [:show] do
          get "/:id/:page" => :show, :on => :member
    	end
    	resources :articles, :only => [:show] do
          get "plain", :on => :member
    	  get "/:data/:id/page/:page_id" => :page, :on => :collection, :as => :page
    	  get "/:data/:id" => :show, :on => :collection
    	end
    end

    namespace "console" do


      namespace :premium do
        resources :touzibao_cases do
        end
        resources :touzibaos do
          member do
            get :print
            put :publish
            put :unpublish
            get :change_pos
          end
          resources :articles, :controller => :touzibao_articles, :except => [:index] do
          end
        end

        resources :mobile_news do
        end

        resources :feedbacks, :only => [:index] do

        end
        resources :mobile_newspaper_accounts, :only => [:index] do
          collection do
            get :plain
            get :search
          end
        end
        resources :activated_user_records, :only => [:index] do
          get :download, :on => :member
        end
        resources :service_cards do
          collection do
            get :download
            get :upload_file
            post :upload
            get :download_file
          end
        end
      end


      resources :article_logs, :only => [:index] do
        
        collection do
          get "published", :as => :published
          get "banned", :as => :banned
          get "updated", :as => :updated
          get "deleted", :as => :deleted
          
          get "/detail/:article_id" => :detail, :as => :detail
        end
      end
      resources :polls do
      end
      resources :ad_positions do
        resources :ads, :only => [:index]
        get :update_size, :on => :collection
      end
      resources :ads, :except => [:index] do
        get :active, :on => :member
      end

      resources :columnists

      resources :staffs,  :only => [:index,:create,:edit,:update, :new]do 
        post "ban_staff", :on => :member
        post "active_staff", :on => :member
        get "show_articles", :on => :member
      end

      resource :staff ,:only =>[] do
        post "update_target"
        match 'change_password' => :change_password, :as => "change_password"
      end


      
      resources :lives do
        get :stock, :on => :collection
        get :origin, :on => :collection
        get :add_guest, :on => :collection
        get :change_live_show_type, :on => :collection
      end
    
      resource :search, :only => [] do
        collection do
          get "/article_search" => :article_search, :as => :article_search
          get "/weibo_search" => :weibo_search, :as => :weibo_search  
          get "/image_search" => :image_search, :as => :image_search
        end
        
      end
    
      resources :comments, :only => [:index, :destroy] do
        post "ban", :on => :member
        post "unban", :on => :member
        post "ban_comments", :on => :collection
        post "destroy_comments", :on => :collection
      end
      
      resources :columns, :only => [:show] do
        get "expire_all_fragment", :on => :collection
        get "fragment_cache_manage", :on => :collection
        get "change_pos", :on => :member
        get "change_pos_to_first", :on => :member
        post "remove_articles", :on => :member
        post "add_articles", :on => :member
        post "column_list" => :column_list, :as => "column_list", :on => :collection
      end
      
      resources :newspapers do
        post :publish, :on => :member
        post :unpublish, :on => :member
        post :upload_file, :on => :collection
        get :new_article, :on => :member
        post :create_article, :on => :member
        get :check_status, :on => :member
      end
      
      controller :sessions do
        get "sign_in" => :new
        post "sign_in" => :create
        delete "sign_out" => :destroy
      end

      resources :articles_children, :only => [:create, :update] do
        post "new_article", :on => :collection
      end
      
      resources :articles, :except => [:show] do 
        get "manage_children_article"
        put "manage_children_article"
        post "add_child_article", :on => :member
        post "remove_child_article", :on => :member
        get "change_children_articles_pos", :on => :member
        post "change_status", :on => :member
        get "article_logs", :on => :member
        collection do
          get "published"
          get 'draft'
          get 'banned'
          post "staff_articles" => :staff_articles, :as => "staff_articles"
          post "dynamic_articles" => :dynamic_articles, :as => "dynamic_articles"
          post "remove_articles" => :remove_articles, :as => :remove_articles
          get 'stats'
          get 'top_stats'
          get "dynamic_search"
          get "search_by_ids"
          post "ban_by_ids"
        end
      end
      
      resources :features, :except => [:show] do
        get "update_banner", :on => :member
        get "image_cell_frame", :on => :collection
        resources :feature_pages do
        end
      end

      resources :images do
        get :upload_images, :on => :collection
        post :update_desc, :on => :collection
      end
      
      resources :feature_pages, :only =>[] do
        resources :elements
        resources :element_images, :controller => :elements, :type => "image"
        resources :element_texts, :controller => :elements, :type => "text"
        resources :element_htmls, :controller => :elements, :type => "html"
        resources :element_links, :controller => :elements, :type => "link"
        resources :element_articles, :controller => :elements, :type => "article"
        resources :element_features, :controller => :elements, :type => "feature"
        resources :element_cweibos, :controller => :elements, :type => "cweibo"
        resources :element_titles, :controller => :elements, :type => "title"
        resources :element_polls, :controller => :elements, :type => "poll"
        resources :element_image_cells, :controller => :elements, :type => "image_cell"
        
        member do
          get 'choose_section' => :choose_section, :as => :choose_section
          post "delete_section" => :delete_section, :as => :delete_section
          post 'create_section' => :create_section, :as => :create_section
          post 'update_layout' => :update_layout, :as => :update_layout
        end
      end
      post 'fetch_section_template' => :fetch_section_template, :as => :fetch_section_template, :controller => :feature_pages
      
      
      resources :topics do
        get "change_topic_pos", :on => :member
        post "ban_topics", :on => :collection
        post "del_topics", :on => :collection
        resources :elements
        
        resources :element_images, :controller => :elements, :type => "image"
        resources :element_texts, :controller => :elements, :type => "text"
        resources :element_htmls, :controller => :elements, :type => "html"
        resources :element_links, :controller => :elements, :type => "link"
        resources :element_articles, :controller => :elements, :type => "article"
        resources :element_features, :controller => :elements, :type => "feature"
        resources :element_cweibos, :controller => :elements, :type => "cweibo"
        resources :element_titles, :controller => :elements, :type => "title"
        resources :element_polls, :controller => :elements, :type => "poll"
        
        member do
          delete "ban"
          post "unban"
          post 'update_layout'
          match 'edit_banner'
        end
        
        collection do
          get "published"
          get "draft"
          get "banned"
          get "hot_tags"
        end
      end
      
      resources :weibos do
        member do
          delete "ban"
          post "unban"
        end
        
        collection do
          get "hot_rt"
          get "hot_comment"
          get "sys_weibos"
          get "banned"
          post "toggle_content_check_status"
          post "change_status"
          post "delete_weibos"
        end
      end
      
      resources :elements
      
      resources :badkeywords
      resources :badwords do 
        get 'search', :on => :collection
      end
      
      resources :notices do
        get "list", :on => :collection
      end
    
    end

    
    resources :articles, :only => [:show] do
      get "/:date/:id/page/:page_id" => :page, :on => :collection, :as => :page
      get "/:date/:id" => :show, :on => :collection
      get "/:date/:id/print" => :print, :on => :collection, :as => :print
    end
    
    controller :registrations do
      get "user/sign_up" => :new, :as => "sign_up"
      post "user/sign_up" => :create
      get "user/sign_up_pending" => :sign_up_pending
      get "user/activate/:id" => :activate, :as => "activate_user"
      get "user/activate_expiry" => :activate_expiry, :as => "activate_expiry"
      post "user/resend_activate" => :resend_activate, :as => "resend_activate"
      get "user/bind_account" => :bind_account, :as => "bind_account"
      get "reload_captcha" => :reload_captcha, :as => "reload_captcha"
    end
    
    controller :sessions do
      get "user/sign_in" => :new, :as => "user_sign_in"
      post "user/sign_in" => :create
      delete "user/sign_out" => :destroy
    end
    
    get "password_resets/email_sent" => "password_resets#email_sent", :as => "password_reset_email_sent"
    resources :password_resets
    
    namespace "logs" do
      resources :website_logs, :only => [:index, :show]
      resources :jiujiuai_polls, :only => [] do
        get "result" => :result, :on => :member
      end
    end

    
  end
  
  constraints :subdomain => T_EXP do
    resources :live_talks, :except => [:index] do
      member do
        get "ban"
        get "unban"
      end
      resources :live_answers, :only =>[:index, :create]
    end
    resources :live_answers, :only => [:destroy]
    
    resources :lives do
      member do
        get "fetch_new"
        get "check_new"
        get "questions"
        get "out_link"
      end
      
      collection do
        get "/:date/:id" => :show
        get 'today'
      end

    end
    
    root :to => "community_home#index", :as => "weibo_host"
    
    match "/n/:nickname" => "users#n", :as => "n_user"
    #get "/:user_id/weibos/:weibo_id" => "weibos#show", :as => "weibo_details"
    
    resources :users, :path => "" do
      member do
        get "profile" 
        get "fans" => :followers, :as => "followers"
        get "follows" => :followings, :as => "followings"
        get "stocks"
        
        get "check_status"
        
        get "atme"
        get "atme_comments"
        get "comments"
        get "comments_to_me"
        get "favs"
        
        post "follow"
        post "unfollow"
        
        match 'step_1' => :step_1, :as => "step_1"
        #get 'step_2' => :step_2, :as => "step_2"

      end
    end
    
    resource :user do
      match 'settings' => :settings, :as => "settings"
      match 'change_password' => :change_password, :as => "change_password"
      get 'weibo_accounts', :as => "weibo_accounts"
    end
    
    resources :weibos, :only => [:update, :create, :show, :destroy] do
      get "fetch_new", :on => :collection
    end
    
    match "/n/:nickname" => "users#n"
    #get "/:user_id/weibos/:weibo_id" => "weibos#show", :as => "weibo_details"
    
    resources :authentications, :only => [:create, :destroy] do
      get '/auth/:provider/callback' => :craete
    end
    
    resources :topics, :only => [:show]
    
    resources :stocks
  end


  
  #route rule
  # match 'user/:user_id/' => 'home#index'
  
  # The priority is based upon order of creation:
  # first created -> highest priority.
  
  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action
  
  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)
  
  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products
  
  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end
  
  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end
  
  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end
  
  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
  
  # See how all your routes lay out with "rake routes"
  
  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
   match ':controller(/:action(/:id(.:format)))'
  #end
end
