DROP TABLE IF EXISTS `jiujiuai_poll_records`;
CREATE TABLE `jiujiuai_poll_records`(
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `poll_id` int(11) NOT NULL,
  `poll_option_id` int(11) NOT NULL,
  `current_vote_count` int(11),
  `record_at`  datetime NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_polls_on_jiujiuai_polls_records` (`poll_id`, `poll_option_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;