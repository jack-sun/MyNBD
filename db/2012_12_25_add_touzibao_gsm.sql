
--投资宝-股东大会实录，用户账号
DROP TABLE IF EXISTS `gms_accounts`; 
CREATE TABLE `gms_accounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `plan_type` int(11) NOT NULL DEFAULT -1,
  `last_active_from` int(11) NOT NULL,
  `last_payment_at` datetime DEFAULT NULL,
  `access_token` varchar(255) NOT NULL,
  `access_token_updated_at` datetime NOT NULL,
  `last_activated_device` varchar(32) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_user_id_on_gms_accounts` (`user_id`),
  KEY `index_access_token_on_gms_accounts` (`access_token`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--投资宝-股东大会实录，文章详情记录
DROP TABLE IF EXISTS `gms_articles`; 
CREATE TABLE `gms_articles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `article_id` int(11) NOT NULL,
  `staff_id` int(11) NOT NULL,
  `stock_code` varchar(32),
  `stock_name` varchar(32),
  `stock_company` varchar(32),
  `cost_credits` int(11) NOT NULL DEFAULT 20,
  `is_remove_from_sale` int(4) NOT NULL DEFAULT 0,
  `is_preview` int(4) NOT NULL DEFAULT 0,
  `meeting_at` datetime DEFAULT NULL,
  `status` int(11) NOT NULL DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_stock_on_gms_articles` (`stock_code`, `stock_name`, `stock_company`),
  KEY `index_meeting_at_on_gms_articles` (`meeting_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--投资宝-股东大会实录，用户文章购买记录
DROP TABLE IF EXISTS `gms_accounts_articles`;
CREATE TABLE `gms_accounts_articles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `gms_account_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `gms_article_id` int(11) NOT NULL,
  `is_receive_refund` int(4),
  `cost_credits` int(11) NOT NULL DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_gms_account_id_on_gms_accounts_articles` (`gms_account_id`, `user_id`),
  KEY `index_article_id_on_gms_accounts_articles` (`gms_article_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


--用户信用点充值、消费流水账记录
DROP TABLE IF EXISTS `credit_logs`;
CREATE TABLE `credit_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `cmd` int(11) NOT NULL,
  `credits` int(11) NOT NULL DEFAULT 0,
  `product_type` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_id_on_credit_logs` (`user_id`),
  KEY `index_cmd_on_credit_logs` (`cmd`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- stocks 1.新增company字段 2. code字段是创建 unique key, 3. 新增 allow_touzibao_comment
DROP TABLE IF EXISTS `stocks`; 
CREATE TABLE `stocks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(32) NOT NULL,
  `code` varchar(32) NOT NULL,
  `company` varchar(32) DEFAULT NULL,
  `followers_count` int(11) DEFAULT NULL,
  `weibos_count` int(11) DEFAULT NULL,
  `allow_touzibao_comment` int(4) NOT NULL DEFAULT '1',
  `comments_count` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_code_on_stocks` (`code`),
  KEY `index_stocks_on_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 新增股票提问表 stock_questions
DROP TABLE IF EXISTS `stock_comments`; 
CREATE TABLE `stock_comments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `real_name` varchar(32),
  `phone_no` varchar(32),
  `stock_code` varchar(32),
  `stock_name` varchar(32),
  `stock_company` varchar(32),
  `comment` text,
  `status` int(11) NOT NULL DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--每经信用点
-- users表，新增credits字段,  新增 phone_no, real_name 字段
alter table `users`
add `credits` int(11) NOT NULL DEFAULT 0,
add `phone_no` varchar(32),
add `real_name` varchar(32);



