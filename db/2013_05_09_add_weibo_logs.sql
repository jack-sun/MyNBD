CREATE TABLE `weibo_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `weibo_id` int(11) NOT NULL,
  `staff_id` int(11) NOT NULL,
  `cmd` int(6) NOT NULL,
  `remote_ip` varchar(255) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `weibo_id_on_weibo_logs` (`weibo_id`),
  KEY `staff_id_on_weibo_logs` (`staff_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `community_switch_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `staff_id` int(11) NOT NULL,
  `cmd` int(6) NOT NULL,
  `remote_ip` varchar(255) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
