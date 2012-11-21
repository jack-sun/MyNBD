--新增问题回答数
alter table live_talks
add `answer_count` int(11) NOT NULL DEFAULT 0;