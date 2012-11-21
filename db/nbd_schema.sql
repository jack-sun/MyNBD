
use nbd;

DROP TABLE IF EXISTS `articles`;
CREATE TABLE `articles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `list_title` varchar(255) DEFAULT NULL,
  `sub_title` varchar(255) DEFAULT NULL,
  `digest` varchar(300) DEFAULT NULL,
  `a_type` int(11) NOT NULL DEFAULT '0',
  `slug` varchar(32) NOT NULL,
  `redirect_to` varchar(255) DEFAULT NULL,
  `is_rolling_news` int(11) DEFAULT '0',
  `ori_author` varchar(64) DEFAULT NULL,
  `ori_source` varchar(64) DEFAULT NULL,
  `image_id` int(11) DEFAULT NULL,
  `click_count` int(11) DEFAULT '0',
  `allow_comment` int(11) DEFAULT '1',  
  `weibo_id` int(11) NOT NULL DEFAULT '0',
  `max_child_pos` int(11) NOT NULL DEFAULT '0',
  `tags` varchar(255) DEFAULT NULL,
  `status` int(11) DEFAULT '0',
  `delta` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_articles_on_slug` (`slug`),
  KEY `index_articles_on_is_rolling_news` (`is_rolling_news`),
  KEY `index_articles_on_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `articles_children`;
CREATE TABLE `articles_children` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `article_id` int(11) NOT NULL,
  `children_id` int(11) NOT NULL,
  `pos` int(11) NOT NULL DEFAULT '1',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_articles_children_on_article_id_and_children_id` (`article_id`, `children_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `articles_columns`;
CREATE TABLE `articles_columns` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `article_id` int(11) NOT NULL,
  `column_id` int(11) NOT NULL,
  `pos` int(11) NOT NULL DEFAULT '1',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `status` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_articles_columns_on_article_id_and_column_id` (`article_id`, `column_id`),
  KEY `key_column_id_pos` (`column_id`,`pos`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `articles_newspapers`;
CREATE TABLE `articles_newspapers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `article_id` int(11) NOT NULL,
  `newspaper_id` int(11) NOT NULL,
  `section` varchar(64) NOT NULL,
  `page` varchar(64) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_articles_newspapers_on_newspaper_id` (`newspaper_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `articles_staffs`;
CREATE TABLE `articles_staffs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `article_id` int(11) NOT NULL,
  `staff_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_articles_staffs_on_article_id` (`article_id`),
  KEY `index_articles_staffs_on_staff_id` (`staff_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `authentications`;
CREATE TABLE `authentications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `provider` varchar(255) NOT NULL,
  `uid` varchar(255) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_authentications_on_user_id_and_provider` (`user_id`, `provider`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `badkeywords`;
CREATE TABLE `badkeywords` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `staff_id` int(11) NOT NULL,
  `value` varchar(255) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_badkeywords_on_value` (`value`),
  KEY `index_badkeywords_on_staff_id` (`staff_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `columns`;
CREATE TABLE `columns` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `slug` varchar(255) DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `max_pos` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `columns_users`;
CREATE TABLE `columns_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `column_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `comment_logs`;
CREATE TABLE `comment_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `comment_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_comment_logs_on_user_id` (`user_id`),
  KEY `index_comment_logs_on_comment_id` (`comment_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `comments`;
CREATE TABLE `comments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `weibo_id` int(11) NOT NULL,
  `ori_weibo_id` int(11) NOT NULL,
  `content` text NOT NULL,
  `status` int(11) NOT NULL DEFAULT '1',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_comments_on_user_id` (`user_id`),
  KEY `index_comments_on_weibo_id` (`weibo_id`),
  KEY `index_comments_on_ori_weibo_id` (`ori_weibo_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `elements`;
CREATE TABLE `elements` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `owner_id` int(11) NOT NULL,
  `owner_type` varchar(64) NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `type` varchar(64) NOT NULL,
  `content` varchar(5000) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_elements_columns_on_feature_page_id` (`owner_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `features`;
CREATE TABLE `features` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `desc` varchar(300) DEFAULT NULL,
  `click_count` int(11) DEFAULT '0',
  `staff_id` int(11) NOT NULL,
  `theme` varchar(255) NOT NULL DEFAULT 'default',
  `banner` varchar(1500) NOT NULL DEFAULT '',
  `allow_comment` int(11) DEFAULT '1',
  `weibo_id` int(11) NOT NULL DEFAULT '0',
  `status` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_features_columns_on_slug` (`slug`),
  KEY `index_features_columns_on_staff_id` (`staff_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `features_pages`;
CREATE TABLE `features_pages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `feature_id` int(11) NOT NULL,
  `layout` varchar(3000) NOT NULL,
  `pos` int(11) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_features_pages_columns_on_feature_id` (`feature_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `followers`;
CREATE TABLE `followers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `follower_user_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_followers_on_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `followings`;
CREATE TABLE `followings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `following_user_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_followings_on_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `images`;
CREATE TABLE `images` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `article` varchar(255) DEFAULT NULL,
  `avatar` varchar(255) DEFAULT NULL,
  `weibo` varchar(255) DEFAULT NULL,
  `feature` varchar(255) DEFAULT NULL,
  `topic` varchar(255) DEFAULT NULL,
  `desc` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `mentions`;
CREATE TABLE `mentions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `target_id` int(11) NOT NULL,
  `target_type` varchar(255) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_mentions_on_user_id` (`user_id`),
  KEY `index_mentions_on_target_id` (`target_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `newspapers`;
CREATE TABLE `newspapers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `n_index` varchar(64) NOT NULL,
  `staff_id` int(11) NOT NULL,
  `status` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_newspapers_on_n_index` (`n_index`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `notifications`;
CREATE TABLE `notifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `recipient_id` int(11) NOT NULL,
  `target_id` int(11) NOT NULL,
  `target_type` varchar(255) NOT NULL,
  `unread` int(11) DEFAULT '1',
  `type` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_notifications_on_recipient_id` (`recipient_id`),
  KEY `index_notifications_on_target_id` (`target_id`),
  KEY `index_notifications_on_unread` (`unread`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `pages`;
CREATE TABLE `pages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `article_id` int(11) NOT NULL,
  `content` text,
  `image_id` int(11) DEFAULT NULL,
  `video` varchar(255) DEFAULT NULL,
  `p_index` int(11) DEFAULT '1',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_pages_on_article_id` (`article_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `portfolios`;
CREATE TABLE `portfolios` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `stock_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_portfolios_on_user_id_and_stock_id` (`user_id`, `stock_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `schema_migrations`;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `staffs`;
CREATE TABLE `staffs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(64) NOT NULL,
  `real_name` varchar(64) NOT NULL,
  `hashed_password` varchar(32) NOT NULL,
  `salt` varchar(32) DEFAULT NULL,
  `image_id` int(11) DEFAULT '0',
  `email` varchar(64) DEFAULT NULL,
  `phone` varchar(32) DEFAULT NULL,
  `user_type` int(11) NOT NULL,
  `comment` varchar(500) DEFAULT NULL,
  `creator_id` int(11) DEFAULT '0',
  `status` int(11) DEFAULT '1',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_staffs_on_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `staffs_permissions`;
CREATE TABLE `staffs_permissions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `column_id` int(11) NOT NULL,
  `staff_id` int(11) NOT NULL,
  `creator_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_staffs_permissions_on_column_id` (`column_id`),
  KEY `index_staffs_permissions_on_staff_id` (`staff_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `stocks`;
CREATE TABLE `stocks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(32) NOT NULL,
  `code` varchar(32) NOT NULL,
  `followers_count` int(11) DEFAULT NULL,
  `weibos_count` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_stocks_on_name` (`name`),
  KEY `index_stocks_on_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `topics`;
CREATE TABLE `topics` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `staff_id` int(11) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `title` varchar(255) NOT NULL,
  `desc` varchar(255) NOT NULL DEFAULT '',
  `image_id` int(11) NOT NULL DEFAULT '0',
  `pos` int(11) NOT NULL DEFAULT '0',
  `click_count` int(11) DEFAULT '0',
  `layout` varchar(3000) NOT NULL DEFAULT '',
  `status` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `slug` (`slug`),
  KEY `index_topics_columns_on_staff_id` (`staff_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(64) NOT NULL,
  `nickname` varchar(64) NOT NULL,
  `image_id` int(11) DEFAULT NULL,
  `desc` varchar(500) DEFAULT NULL,
  `hashed_password` varchar(64) NOT NULL,
  `salt` varchar(64) NOT NULL,
  `reg_from` int(11) DEFAULT '0',
  `user_type` int(11) DEFAULT '1',
  `auth_token` varchar(32) NOT NULL,
  `status` int(11) NOT NULL DEFAULT '0',
  `password_reset_token` varchar(32) DEFAULT NULL,
  `password_reset_sent_at` datetime DEFAULT NULL,
  `activate_token` varchar(32) DEFAULT NULL,
  `activate_sent_at` datetime DEFAULT NULL,
  `followings_count` int(11) DEFAULT '0',
  `followers_count` int(11) DEFAULT '0',
  `stocks_count` int(11) DEFAULT '0',
  `weibos_count` int(11) DEFAULT '0',
  `verified` int(11) DEFAULT '0',
  `delta` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_users_on_email` (`email`),
  UNIQUE KEY `index_users_on_nickname` (`nickname`),
  UNIQUE KEY `index_users_on_auth_token` (`auth_token`),
  UNIQUE KEY `index_users_on_password_reset_token` (`password_reset_token`),
  UNIQUE KEY `index_users_on_activate_token` (`activate_token`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `weibos`;
CREATE TABLE `weibos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `owner_id` int(11) NOT NULL,
  `owner_type` varchar(255) NOT NULL,
  `has_tag` int(11) DEFAULT '0',
  `content` text NOT NULL,
  `parent_weibo_id` int(11) NOT NULL DEFAULT '0',
  `ori_weibo_id` int(11) NOT NULL DEFAULT '0',
  `rt_count` int(11) DEFAULT '0',
  `reply_count` int(11) DEFAULT '0',
  `weibo_type` int(11) DEFAULT '0',
  `content_type` int(11) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `delta` tinyint(1) NOT NULL DEFAULT '1',
  `status` int(11) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `index_weibos_on_owner_id_and_owner_type` (`owner_id`,`owner_type`),
  KEY `index_weibos_on_parent_weibo_id` (`parent_weibo_id`),
  KEY `index_weibos_on_ori_weibo_id` (`ori_weibo_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

