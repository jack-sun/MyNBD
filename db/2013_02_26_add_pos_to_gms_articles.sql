alter table `gms_articles`
add `pos` int(11) NOT NULL DEFAULT 1;

alter table `mn_accounts`
add `is_receive_credits` int(4) NOT NULL DEFAULT 0;
