DROP TABLE IF EXISTS `payments`; 
rDROP TABLE IF EXISTS `payments`; 
CREATE TABLE `payments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT 0,
  `trade_type` int(11) DEFAULT 0,
  `trade_no` varchar(32) DEFAULT "",
  `status` int(11) DEFAULT 0,
  `payment_type` int(11) DEFAULT 0,
  `service_card_id` int(11) DEFAULT 0,
  `payment_total_fee` decimal(6,2) NOT NULL DEFAULT '0',
  `service_type` varchar(64) DEFAULT "",
  `service_id` int(11) DEFAULT 0,
  `buyer_email` varchar(255) DEFAULT "",
  `raw_trade` varchar(1000) DEFAULT "",
  `invoice_id` int(11) DEFAULT 0,
  `payment_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_payments_on_service_card_no` (`service_card_id`),
  KEY `index_payments_on_service_type_and_service_no` (`service_type`, `service_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `mn_accounts`; 
CREATE TABLE `mn_accounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT 0,
  `service_type` int(11) NOT NULL,
  `phone_no` varchar(32) DEFAULT "",
  `last_active_from` int(11) NOT NULL,
  `last_payment_at` datetime DEFAULT NULL,
  `service_end_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_mobile_newspaper_accounts_on_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `invoices`; 
CREATE TABLE `invoices` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT 0,
  `i_type` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `body` varchar(255) NOT NULL,
  `address` varchar(255) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_invoices_on_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `service_cards`; 
CREATE TABLE `service_cards` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `card_no` varchar(16) NOT NULL,
  `password` varchar(16) NOT NULL,
  `card_type` int(11) DEFAULT 0,
  `status` int(11) DEFAULT 0,
  `service_id` int(11) DEFAULT 0,
  `service_type` varchar(64) DEFAULT "",
  `activated_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_service_cards_on_service_type_and_service_no` (`service_type`, `service_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

alter table mn_accounts
add `last_sended_at` datetime DEFAULT NULL;

DROP TABLE IF EXISTS `activated_user_records`; 
CREATE TABLE `activated_user_records` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `count` int(11) NOT NULL,
  `staff_id` int(11) NOT NULL,
  `file_name` varchar(64) DEFAULT "",
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `feedbacks`; 
CREATE TABLE `feedbacks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `phone_no` varchar(32) DEFAULT "",
  `real_name` varchar(32) DEFAULT "",
  `email` varchar(64) DEFAULT "",
  `body` varchar(500) DEFAULT "",
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
