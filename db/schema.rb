# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111026062611) do

  create_table "articles", :force => true do |t|
    t.string   "title",                                         :null => false
    t.string   "list_title"
    t.string   "sub_title"
    t.string   "digest",          :limit => 300
    t.integer  "a_type",                         :default => 0, :null => false
    t.string   "slug",            :limit => 32,                 :null => false
    t.string   "redirect_to"
    t.string   "ori_author",      :limit => 64
    t.string   "ori_source",      :limit => 64
    t.string   "comment",         :limit => 300
    t.integer  "image_id"
    t.integer  "click_count",                    :default => 0
    t.integer  "max_child_pos",                  :default => 0, :null => false
    t.integer  "allow_comment",                  :default => 1
    t.integer  "status",                         :default => 0
    t.integer  "is_rolling_news",                :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "weibo_id",                       :default => 0, :null => false
  end

  add_index "articles", ["is_rolling_news"], :name => "index_articles_on_is_rolling_news"

  create_table "articles_children", :force => true do |t|
    t.integer  "article_id",                 :null => false
    t.integer  "children_id",                :null => false
    t.integer  "pos",         :default => 1, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "articles_children", ["article_id"], :name => "index_articles_children_on_article_id"
  add_index "articles_children", ["children_id"], :name => "index_articles_children_on_children_id"

  create_table "articles_columns", :force => true do |t|
    t.integer  "article_id",                :null => false
    t.integer  "column_id",                 :null => false
    t.integer  "pos",        :default => 1, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status",     :default => 0, :null => false
  end

  add_index "articles_columns", ["article_id"], :name => "index_articles_columns_on_article_id"
  add_index "articles_columns", ["column_id", "pos"], :name => "key_column_id_pos"
  add_index "articles_columns", ["column_id"], :name => "index_articles_columns_on_column_id"

  create_table "articles_newspapers", :force => true do |t|
    t.integer  "article_id",                 :null => false
    t.integer  "newspaper_id",               :null => false
    t.string   "section",      :limit => 64, :null => false
    t.string   "page",         :limit => 64, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "articles_newspapers", ["newspaper_id"], :name => "index_articles_newspapers_on_newspaper_id"

  create_table "articles_staffs", :force => true do |t|
    t.integer  "article_id", :null => false
    t.integer  "staff_id",   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "articles_staffs", ["article_id"], :name => "index_articles_staffs_on_article_id"
  add_index "articles_staffs", ["staff_id"], :name => "index_articles_staffs_on_staff_id"

  create_table "authentications", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.string   "provider",   :null => false
    t.string   "uid",        :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "columns", :force => true do |t|
    t.string   "name",                      :null => false
    t.integer  "parent_id"
    t.integer  "max_pos",    :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "columns_users", :force => true do |t|
    t.integer  "column_id",  :null => false
    t.integer  "user_id",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comment_logs", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.integer  "comment_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comment_logs", ["comment_id"], :name => "index_comment_logs_on_comment_id"
  add_index "comment_logs", ["user_id"], :name => "index_comment_logs_on_user_id"

  create_table "comments", :force => true do |t|
    t.integer  "user_id",      :null => false
    t.integer  "weibo_id",     :null => false
    t.integer  "ori_weibo_id", :null => false
    t.text     "content",      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "demos", :force => true do |t|
    t.boolean  "delta",      :default => true, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "elements", :force => true do |t|
    t.integer  "feature_page_id",                 :null => false
    t.string   "title"
    t.string   "type",            :limit => 64,   :null => false
    t.string   "content",         :limit => 5000, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "elements", ["feature_page_id"], :name => "index_elements_columns_on_feature_page_id"

  create_table "features", :force => true do |t|
    t.string   "title",                                                :null => false
    t.string   "slug",                                                 :null => false
    t.string   "desc",          :limit => 300
    t.integer  "click_count",                   :default => 0
    t.integer  "staff_id",                                             :null => false
    t.string   "theme",                         :default => "default", :null => false
    t.string   "banner",        :limit => 1500, :default => "",        :null => false
    t.integer  "status",                        :default => 0,         :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "allow_comment",                 :default => 1
    t.integer  "weibo_id",                      :default => 1,         :null => false
  end

  add_index "features", ["slug"], :name => "index_features_columns_on_slug"
  add_index "features", ["staff_id"], :name => "index_features_columns_on_staff_id"

  create_table "features_pages", :force => true do |t|
    t.integer  "feature_id",                                      :null => false
    t.string   "slug",                       :default => "index", :null => false
    t.string   "layout",     :limit => 5000,                      :null => false
    t.integer  "pos",                        :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "features_pages", ["feature_id"], :name => "index_features_pages_columns_on_feature_id"
  add_index "features_pages", ["slug"], :name => "index_features_pages_columns_on_slug"

  create_table "followers", :force => true do |t|
    t.integer  "user_id",          :null => false
    t.integer  "follower_user_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "followers", ["user_id"], :name => "index_followers_on_user_id"

  create_table "followings", :force => true do |t|
    t.integer  "user_id",           :null => false
    t.integer  "following_user_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "followings", ["user_id"], :name => "index_followings_on_user_id"

  create_table "images", :force => true do |t|
    t.string   "article"
    t.text     "desc"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "avatar"
    t.string   "weibo"
  end

  create_table "mentions", :force => true do |t|
    t.integer  "user_id",     :null => false
    t.integer  "target_id",   :null => false
    t.string   "target_type", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "newspapers", :force => true do |t|
    t.string   "n_index",    :limit => 64,                :null => false
    t.integer  "staff_id",                                :null => false
    t.integer  "status",                   :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notifications", :force => true do |t|
    t.integer  "recipient_id",                :null => false
    t.integer  "target_id",                   :null => false
    t.string   "target_type",                 :null => false
    t.integer  "unread",       :default => 1
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pages", :force => true do |t|
    t.integer  "article_id",                :null => false
    t.text     "content",                   :null => false
    t.integer  "image_id"
    t.string   "video"
    t.integer  "p_index",    :default => 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pages", ["article_id"], :name => "index_pages_on_article_id"

  create_table "portfolios", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.integer  "stock_id",   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "staffs", :force => true do |t|
    t.string   "name",            :limit => 64,                 :null => false
    t.string   "real_name",       :limit => 64,                 :null => false
    t.string   "hashed_password", :limit => 32,                 :null => false
    t.string   "salt",            :limit => 32
    t.integer  "image_id",                       :default => 0
    t.string   "email",           :limit => 64
    t.string   "phone",           :limit => 32
    t.integer  "user_type",                                     :null => false
    t.string   "comment",         :limit => 500
    t.integer  "creator_id",                     :default => 0
    t.integer  "status",                         :default => 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "staffs_permissions", :force => true do |t|
    t.integer  "column_id",  :null => false
    t.integer  "staff_id",   :null => false
    t.integer  "creator_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "staffs_permissions", ["column_id"], :name => "index_staffs_permissions_on_column_id"
  add_index "staffs_permissions", ["staff_id"], :name => "index_staffs_permissions_on_staff_id"

  create_table "stocks", :force => true do |t|
    t.string   "name",            :limit => 32, :null => false
    t.string   "code",            :limit => 32, :null => false
    t.integer  "followers_count"
    t.integer  "weibos_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tags", :force => true do |t|
    t.string   "name",         :limit => 64,                :null => false
    t.integer  "daily_count",                :default => 0
    t.datetime "last_post_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tags_weibos", :force => true do |t|
    t.integer  "tag_id",     :null => false
    t.integer  "weibo_id",   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tags_weibos", ["tag_id"], :name => "index_tags_weibos_on_tag_id"
  add_index "tags_weibos", ["weibo_id"], :name => "index_tags_weibos_on_weibo_id"

  create_table "users", :force => true do |t|
    t.string   "email",                  :limit => 64,                :null => false
    t.string   "nickname",               :limit => 64,                :null => false
    t.string   "hashed_password",        :limit => 64,                :null => false
    t.string   "salt",                   :limit => 64,                :null => false
    t.integer  "reg_from",                             :default => 0
    t.integer  "user_type",                            :default => 1
    t.string   "auth_token",             :limit => 32,                :null => false
    t.integer  "status",                               :default => 0, :null => false
    t.string   "password_reset_token",   :limit => 32
    t.datetime "password_reset_sent_at"
    t.string   "activate_token",         :limit => 32
    t.datetime "activate_sent_at"
    t.integer  "followings_count",                     :default => 0
    t.integer  "followers_count",                      :default => 0
    t.integer  "stocks_count",                         :default => 0
    t.integer  "weibos_count",                         :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["activate_token"], :name => "index_users_on_activate_token", :unique => true
  add_index "users", ["auth_token"], :name => "index_users_on_auth_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["nickname"], :name => "index_users_on_nickname", :unique => true
  add_index "users", ["password_reset_token"], :name => "index_users_on_password_reset_token", :unique => true

  create_table "weibos", :force => true do |t|
    t.integer  "owner_id",                       :null => false
    t.string   "owner_type",                     :null => false
    t.integer  "has_tag",         :default => 0
    t.text     "content",                        :null => false
    t.integer  "parent_weibo_id", :default => 0, :null => false
    t.integer  "ori_weibo_id",    :default => 0, :null => false
    t.integer  "rt_count",        :default => 0
    t.integer  "reply_count",     :default => 0
    t.integer  "weibo_type",      :default => 0
    t.integer  "content_type",    :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "weibos", ["owner_id", "owner_type"], :name => "index_weibos_on_owner_id_and_owner_type"

end
