DROP TABLE IF EXISTS `staff_performance_logs`; 
CREATE TABLE `staff_performance_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `staff_id` int(11) NOT NULL,
  `date_at` date NOT NULL,
  `post_count` int(11) NOT NULL DEFAULT 0,
  `click_count` int(11) NOT NULL DEFAULT 0,
  `convert_count` int(11) NOT NULL DEFAULT 0,
  `convert_count_reviewed` int(4) NOT NULL DEFAULT 0,
  `convert_apply_comment` varchar(500),
  `review_staff_id` int(11) NOT NULL DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_staff_id_and_date_at_on_staff_performance_logs` (`staff_id`, `date_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `column_performance_logs`; 
CREATE TABLE `column_performance_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `column_id` int(11) NOT NULL,
  `parent_column_id` int(11) NOT NULL,
  `date_at` date NOT NULL,
  `post_count` int(11) NOT NULL DEFAULT 0,
  `click_count` int(11) NOT NULL DEFAULT 0,
  `staff_id` int(11) NOT NULL DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_column_id_and_date_at_on_column_performance_logs` (`column_id`, `date_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

