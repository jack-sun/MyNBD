DROP TABLE IF EXISTS `galleries`; 
CREATE TABLE `galleries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `staff_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL, 
  `desc` varchar(1500),
  `click_count` int(11) NOT NULL DEFAULT 0,
  `tags` varchar(255),
  `watermark` int(4) NOT NULL DEFAULT 0,
  `max_pos` int(11) NOT NULL DEFAULT 0, 
  `status` int(4) NOT NULL DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `gallery_images`; 
CREATE TABLE `gallery_images` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `gallery_id` int(11) NOT NULL,
  `image_id` int(11) NOT NULL,
  `desc` varchar(1500) NOT NULL,
  `pos` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_gallery_id_and_image_id_on_gallery_images` (`gallery_id`, `image_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

ALTER table `articles`
add `gallery_id` int(11);

ALTER table `images`
add `gallery` varchar(255);
