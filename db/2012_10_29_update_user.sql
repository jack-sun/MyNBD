alter table users
add `access_token` varchar(32),
add `token_updated_at` varchar(32);

alter table mn_accounts
add `last_activated_device` varchar(100);
