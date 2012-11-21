--编辑每日发稿目标
alter table staffs
add `target_per_day` int(11) NOT NULL DEFAULT 0;

--设置staffs表用户角色
update staffs set user_type = 0 where id in (3, 43, 46, 52, 53); -- 网站技术管理员
update staffs set user_type = 1 where id in (11, 17, 49, 189); -- 网站编辑管理员

--后台通告
CREATE TABLE `notices` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `staff_id` int(11) NOT NULL,
  `content`  varchar(3000) NOT NULL,
  `status`   int(11) NOT NULL DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


