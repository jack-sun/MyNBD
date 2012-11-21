DROP TABLE IF EXISTS `polls`;
CREATE TABLE `polls`(
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `desc` varchar(255),
  `owner_id` int(11),
  `owner_type` varchar(255),
  `need_capcha` int(11) NOT NULL DEFAULT 0,
  `repeats_verify_type` int(11) NOT NULL DEFAULT 0,
  `show_result` int(11) NOT NULL DEFAULT 0,
  `total_vote_count` int(11) NOT NULL DEFAULT 0,
  `max_choice_count` int(11) NOT NULL DEFAULT 1,
  `p_type` int(11) NOT NULL DEFAULT 0,
  `status` int(11) NOT NULL DEFAULT 0,
  `staff_id` int(11) NOT NULL DEFAULT 0,
  `expired_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_polls_on_owner` (`owner_id`, `owner_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `polls_options`;
CREATE TABLE `polls_options`(
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `poll_id` int(11) NOT NULL,
  `pos` int(11) NOT NULL DEFAULT 1,
  `content` varchar(255) NOT NULL,
  `vote_count` int(11) DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_poll_id_on_polls_options` (`poll_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `polls_logs`;
CREATE TABLE `polls_logs`(
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `poll_id` int(11) NOT NULL,
  `user_id` int(11),
  `remote_ip` varchar(32),
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_poll_logs_on_poll_id_user_id_remote_ip` (`poll_id`, `remote_ip`, `user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
