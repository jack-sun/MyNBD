alter table mn_accounts change `service_type` `plan_type` int(11) NOT NULL;
alter table payments
add `plan_type` int(11) NOT NULL;
