ALTER TABLE `kbb_accounts`
ADD `real_name` varchar(32),
ADD `phone_no` varchar(32), 
ADD `email` varchar(64),
ADD `inviter` varchar(32),
ADD `company_name` varchar(32),
ADD `declaration` varchar(1000), 
ADD `sended_mail` tinyint(1) DEFAULT 0;

DROP TABLE IF EXISTS `kbb_votes`;
CREATE TABLE `kbb_votes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `kbb_candidate_id` int(11) NOT NULL,
  `kbb_account_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`), 
  UNIQUE KEY `index_kbb_account_id_and_kbb_candidate_id_on_kbb_votes` (`kbb_account_id`, `kbb_candidate_id`) 
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
