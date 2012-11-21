DROP TABLE IF EXISTS `touzibaos`; 
CREATE TABLE `touzibaos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `staff_id` int(11) DEFAULT 0,
  `status` int(11) DEFAULT 0,
  `max_pos` int(11) DEFAULT 0,
  `t_index` varchar(255) DEFAULT "",
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `article_touzibaos`; 
CREATE TABLE `article_touzibaos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `article_id` int(11) DEFAULT 0,
  `touzibao_id` int(11) DEFAULT 0,
  `section` varchar(64) DEFAULT "",
  `pos` int(11) DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_touzibao_id_and_section_on_article_touzibaos` (`touzibao_id`, `section`, `pos`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
