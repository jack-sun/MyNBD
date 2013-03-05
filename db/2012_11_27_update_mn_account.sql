alter table mn_accounts
add `access_token` varchar(32),
add `access_token_updated_at` varchar(32),
add `last_trade_num` varchar(6),
change `user_id` `user_id` int(11);
