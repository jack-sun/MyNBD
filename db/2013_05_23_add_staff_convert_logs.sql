-- 编辑用户折算发稿量日志
DROP TABLE IF EXISTS `staff_convert_logs`; 
CREATE TABLE `staff_convert_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `staff_id` int(11) NOT NULL,
  `date_at` date NOT NULL,
  `convert_count` int(11) NOT NULL DEFAULT 0,
  `status` int(4) NOT NULL DEFAULT 0,
  `staff_id_in_charge` int(11),
  `comment` varchar(1500),
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_staff_id_and_date_at_on_staff_convert_logs` (`staff_id`, `date_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
