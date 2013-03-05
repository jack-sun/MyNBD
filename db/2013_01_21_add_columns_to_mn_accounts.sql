alter table `mn_accounts`
add column `gift_details` varchar(255),
add column `is_receive_sms` int(11) NOT NULL DEFAULT 1;
