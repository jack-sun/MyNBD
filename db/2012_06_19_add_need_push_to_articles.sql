--新增 “是否需要推送” 字段
alter table articles
add `need_push` int(11) NOT NULL DEFAULT 0;