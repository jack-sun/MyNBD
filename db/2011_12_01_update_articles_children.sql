alter table `articles_children`
add `children_title` varchar(100) NOT NULL,
add `children_url` varchar(255),
change `children_id` `children_id` int(11);
drop index `index_articles_children_on_article_id_and_children_id` on `articles_children`;
create index `index_articles_children_on_article_id_and_pos` on articles_children(article_id, pos);
