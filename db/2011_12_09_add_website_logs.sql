DROP TABLE IF EXISTS `website_logs`; 
CREATE TABLE `website_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `src` int(11) NOT NULL,
  `level` int(11) NOT NULL DEFAULT '0',
  `url` varchar(255) NOT NULL,
  `title` varchar(255) NOT NULL,
  `message` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

