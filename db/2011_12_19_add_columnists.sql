DROP TABLE IF EXISTS `columnists`;
CREATE TABLE `columnists`(
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL UNIQUE,
  `image_id` int(11) NOT NULL,
  `desc` varchar(500) NOT NULL,
  `last_article_id` int(11),
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_columnists_on_slug` (`slug`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `articles_columnists`;
CREATE TABLE `articles_columnists`(
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `article_id` int(11) NOT NULL,
  `columnist_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_articles_columnists_on_article_id_and_columnist_id` (`article_id`,`columnist_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


