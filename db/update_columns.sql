alter table columns add `status` int(11) NOT NULL DEFAULT 1;
update columns set status = 0 where id  in(77,43,46,50,52);
