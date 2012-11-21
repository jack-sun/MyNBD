DROP TABLE IF EXISTS `ads`;
CREATE TABLE `ads`(
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ad_position_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `link` varchar(255) NOT NULL,
  `image_id` int(11) NOT NULL,
  `sponsor` varchar(255) NOT NULL,
  `staff_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_ad_postion_id_on_ads` (`ad_position_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `ad_positions`;
CREATE TABLE `ad_positions`(
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `current_ad_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `desc` varchar(255) NOT NULL,
  `width` int(10) NOT NULL,
  `height` int(10) NOT NULL,
  `price` int(11) NOT NULL DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
