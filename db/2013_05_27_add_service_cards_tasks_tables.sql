DROP TABLE IF EXISTS `card_tasks`; 
CREATE TABLE `card_tasks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `staff_id` int(11) NOT NULL,
  `review_staff_id` int(11), 
  `comment` varchar(2000),
  `status` int(4) NOT NULL DEFAULT 0,
  `proceed` int(4) NOT NULL DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `card_sub_tasks`; 
CREATE TABLE `card_sub_tasks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `card_task_id` int(11) NOT NULL,
  `service_card_type` int(11) NOT NULL,
  `service_card_plan_type` int(11) NOT NULL,
  `service_card_count` int(11) NOT NULL DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_card_task_id_on_card_sub_tasks` (`card_task_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

ALTER table `service_cards`
add `plan_type` int(11) NOT NULL,
add `review_staff_id` int(11) NOT NULL,
add `task_id` int(11);

