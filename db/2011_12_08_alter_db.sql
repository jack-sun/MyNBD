--2011-12-08 统一整理之前的脚本

-- 2011-09-14
alter table articles_columns add KEY key_column_id_pos(column_id, pos);

alter table articles_staffs add KEY index_articles_staffs_on_article_id(article_id);
alter table articles_staffs add KEY index_articles_staffs_on_staff_id(staff_id);

alter table articles_newspapers add KEY index_articles_newspapers_on_newspaper_id(newspaper_id);

alter table articles change is_rollowing_news is_rolling_news int(11) DEFAULT '0';

/* 新增column: ‘深入调查’ */
insert into columns(`id`,`name`,`parent_id`, `max_pos`, `created_at`, `updated_at`)  values (77, '深入调查', 33, 1349, '2011-09-13', '2011-09-13')

alter table images 
change `image` `article` varchar(255),
add `avatar` varchar(255),
add `weibo` varchar(255),
drop column `i_type`;

/* articles_columns增加冗余字段 status，并patch初始值 */
alter table articles_columns
add `status` int(11) NOT NULL DEFAULT '0';

update articles_columns 
set status = 1
where article_id in (select id from articles where status = 1);

update articles_columns 
set status = 0
where article_id in (select id from articles where status = 0);

update articles_columns 
set status = 2
where article_id in (select id from articles where status = 2);
/***********/


/* articles增加index key: is_rolling_news */
alter table articles add KEY index_articles_on_is_rolling_news(is_rolling_news);

--2011-10-11
DROP TABLE IF EXISTS `features`; 
CREATE TABLE `features` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `desc` varchar(300),
  `click_count` int(11) DEFAULT '0',
  `staff_id` int(11) NOT NULL,
  `theme` varchar(255) NOT NULL DEFAULT 'default',
  `banner` varchar(1500) NOT NULL DEFAULT '',
  `status` int(11) NOT NULL DEFAULT '0',
  `allow_comment` int(11) DEFAULT 1,
  `weibo_id` int(11) NOT NULL DEFAULT 0;
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_features_columns_on_staff_id` (`staff_id`),
  KEY `index_features_columns_on_slug` (`slug`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `features_pages`; 
CREATE TABLE `features_pages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `feature_id` int(11) NOT NULL,
  `slug` varchar(255) NOT NULL DEFAULT 'index',
  `layout` varchar(5000) NOT NULL,
  `pos` int(11) default 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_features_pages_columns_on_feature_id` (`feature_id`),
  KEY `index_features_pages_columns_on_slug` (`slug`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `elements`; 
CREATE TABLE `elements` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `feature_page_id` int(11) NOT NULL,
  `title` varchar(255),
  `type` varchar(64) NOT NULL,
  `content` varchar(5000) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_elements_columns_on_feature_page_id` (`feature_page_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


--2011-10-14
alter table articles
add `weibo_id` int(11) NOT NULL default 0;
--rails console:
--Weibo.all.each{|w|a=w.article;next if a.nil?;a.weibo_id=w.id;a.save}
--article.rb:
--belongs_to :weibo
--weibo.rb
--has_one :article
alter table weibos
drop column `article_id`;
alter table images
add `feature` varchar(255);
alter table features
add `allow_comment` int(11) DEFAULT 1;
alter table features_pages
add `pos` int(11) DEFAULT 0;


--2011-10-19
/* 新增column: '首页' 下的子column */
insert into columns(`name`,`parent_id`, `max_pos`, `created_at`, `updated_at`)  values ('NBD特稿', 1, 0, '2011-10-19', '2011-10-19');
insert into columns(`name`,`parent_id`, `max_pos`, `created_at`, `updated_at`)  values ('消费者维权', 1, 0, '2011-10-19', '2011-10-19');

/* 新增column: '市场' 下的子column */
insert into columns(`name`,`parent_id`, `max_pos`, `created_at`, `updated_at`)  values ('机构解盘', 10, 0, '2011-10-19', '2011-10-19');

/* 新增column: '商业' 下的子column */
insert into columns(`name`,`parent_id`, `max_pos`, `created_at`, `updated_at`)  values ('活动会议', 33, 0, '2011-10-19', '2011-10-19');

alter table articles
add `delta` tinyint(1) NOT NULL DEFAULT '1';

alter table users
add `delta` tinyint(1) NOT NULL DEFAULT '1';

alter table weibos
add `delta` tinyint(1) NOT NULL DEFAULT '1';


alter table features_pages
drop column `slug`,
add `title` varchar(255) NOT NULL,
drop index `index_features_pages_columns_on_slug`;
alter table features
change `slug` `slug` varchar(255) NOT NULL UNIQUE;

--2011-10-22
alter table users
add `image_id` int(11) DEFAULT NULL,
add `desc` varchar(500) DEFAULT NULL;


--2011-10-23
alter table weibos
add `status` int(11) DEFAULT 1 NOT NULL;

alter table images 
add `topic` varchar(255);

DROP TABLE IF EXISTS `topics`; 
CREATE TABLE `topics` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `staff_id` int(11) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `title` varchar(255) NOT NULL,
  `desc` varchar(255) NOT NULL DEFAULT '',
  `image_id` int(11) NOT NULL DEFAULT '0',
  `pos` varchar(255) NOT NULL DEFAULT '0',
  `click_count` int(11) DEFAULT '0',
  `layout` varchar(3000) NOT NULL DEFAULT '',
  `status` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `slug` (`slug`),
  KEY `index_topics_columns_on_staff_id` (`staff_id`),
  KEY `index_topics_columns_on_slug` (`slug`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



alter table elements
change feature_page_id owner_id int(11) NOT NULL,
add `owner_type` varchar(64) NOT NULL;
update elements set owner_type = 'FeaturePage';


--2011-10-27
alter table comments
add `status` int(11) DEFAULT 1 NOT NULL;

DROP TABLE IF EXISTS `badkeywords`; 
CREATE TABLE `badkeywords` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `staff_id` int(11) NOT NULL,
  `value` varchar(255) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `value` (`value`),
  KEY `index_topics_columns_on_staff_id` (`staff_id`),
  KEY `index_topics_columns_on_slug` (`value`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


--2011-11-10
alter table comments add `article_id` int(11);
DROP TABLE IF EXISTS `simple_captcha_data`;
CREATE TABLE `simple_captcha_data`(
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `key` char(40),
  `value` char(6),
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY(`id`),
  KEY `idx_key` (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


--2011-11-12
DROP TABLE IF EXISTS `stock_lives`;
CREATE TABLE `stock_lives`(
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `s_index` varchar(64) NOT NULL,
  `title` varchar(255) NOT NULL,
  `desc` varchar(255),
  `user_id` int(11) NOT NULL,
  `click_count` int(11) NOT NULL DEFAULT 0,
  `status` int(11) NOT NULL DEFAULT 0,
  `start_at` datetime NOT NULL,
  `end_at` datetime NOT NULL,
  `created_at` datetime,


  `updated_at` datetime,
  PRIMARY KEY(`id`),
  KEY `s_index_key` (`s_index`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `live_talks`;
CREATE TABLE `live_talks`(
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `live_id` int(11) NOT NULL,
  `live_type` varchar(64) NOT NULL,
  `weibo_id` int(11) NOT NULL,
  `talk_type` int(4) NOT NULL DEFAULT 0,
  `status` int(11) NOT NULL DEFAULT 1,
  `created_at` datetime,
  `updated_at` datetime,
  PRIMARY KEY(`id`),
  KEY `live_talk_type_key` (`live_id`, `live_type`, `talk_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `live_answers`;
CREATE TABLE `live_answers`(
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `weibo_id` int(11) NOT NULL,
  `live_talk_id` int(11) NOT NULL,
  `created_at` datetime,
  `updated_at` datetime,
  PRIMARY KEY(`id`),
  KEY `live_talk_type_key` (`live_talk_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



--2011-11-14
alter table authentications
add `nickname` varchar(64) NOT NULL,
add `access_token` varchar(256) NOT NULL,
add `access_secret` varchar(256) NOT NULL;



--2011-11-22
alter table comments add `parent_comment_id` int(11);



--2011-11-24
alter table articles add `copyright` int(11) NOT NULL DEFAULT 0;


--2011-11-25
alter table topics change `desc` `desc` varchar(1000) NOT NULL DEFAULT '';


--2011-11-28
DROP TABLE IF EXISTS `live_guests`; 
CREATE TABLE `live_guests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `live_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_live_guests_on_live_id_and_user_id` (`live_id`, `user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

alter table stock_lives 
add `tags` varchar(255),
add `l_type` int(11) NOT NULL,
add `image_id` int(11);

alter table images 
add live varchar(255);

alter table weibos 
add `remote_ip` varchar(255);

alter table comments 
add `remote_ip` varchar(255);


--2011-12-01
alter table `articles_children`
add `children_title` varchar(100) NOT NULL,
add `children_url` varchar(255),
change `children_id` `children_id` int(11);
drop index `index_articles_children_on_article_id_and_children_id` on `articles_children`;
create index `index_articles_children_on_article_id_and_pos` on articles_children(article_id, pos);


--2011-12-06
DROP TABLE IF EXISTS `article_logs`;
CREATE TABLE `article_logs`(
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `article_id` int(11) NOT NULL,
  `article_title` varchar(100) NOT NULL,
  `staff_id` int(11) NOT NULL,
  `cmd` int(6) NOT NULL,
  `remote_ip` varchar(255) NOT NULL,
  `created_at` datetime,
  `updated_at` datetime,
  PRIMARY KEY(`id`),
  KEY `article_id_key` (`article_id`),
  KEY `staff_id_key` (`staff_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--2011-12-07
alter table columns 
add `status` int(11) NOT NULL DEFAULT 1;

update columns set status = 2 where id in (77, 41, 43, 46, 50, 52);



