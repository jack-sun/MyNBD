--新增 “是否需要强制投票” 字段
alter table polls
add `mandatory` int(11) NOT NULL DEFAULT 0;
