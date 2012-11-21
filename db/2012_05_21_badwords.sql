DROP TABLE IF EXISTS `badwords`;
CREATE TABLE `badwords`(
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `value` varchar(255) NOT NULL,
  `level` int(11) NOT NULL DEFAULT 0,
  `staff_id` int(11),
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `value` (`value`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;