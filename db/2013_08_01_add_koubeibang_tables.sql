DROP TABLE IF EXISTS `kbbs`; 
CREATE TABLE `kbbs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `k_index` int(11) NOT NULL,
  `title` varchar(255) NOT NULL, 
  `desc` varchar(1500),
  `kbb_candidates_count` int(11) DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_k_index_on_gbbs` (`k_index`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `kbb_candidates`; 
CREATE TABLE `kbb_candidates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `kbb_id` int(11) NOT NULL,
  `stock_code` varchar(32) NOT NULL,
  `stock_company` varchar(32) NOT NULL,
  `thumb_up_count` int(11) NOT NULL DEFAULT 0,
  `thumb_down_count` int(11) NOT NULL DEFAULT 0,
  `kbb_candidate_details_count` int(11) NOT NULL DEFAULT 0,
  `kbb_votes_count` int(11) NOT NULL DEFAULT 0, 
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_kbb_id_and_stock_code_on_kbb_caditates` (`kbb_id`, `stock_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `kbb_candidate_details`;
CREATE TABLE `kbb_candidate_details` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `kbb_candidate_id` int(11) NOT NULL,
  `comment` varchar(1500) NOT NULL,
  `comment_status` int(4) NOT NULL DEFAULT 1,
  `kbb_account_id` int(11),
  `remote_ip` varchar(255) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_kbb_candidate_id_on_kbb_cadidate_details` (`kbb_candidate_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `kbb_accounts`;
CREATE TABLE `kbb_accounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `hashed_password` varchar(64) NOT NULL,
  `salt` varchar(64) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

