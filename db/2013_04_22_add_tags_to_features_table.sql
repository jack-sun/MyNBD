alter table `features`
add `tags` varchar(255)
add `delta` tinyint(1) NOT NULL DEFAULT 1;
