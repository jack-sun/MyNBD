alter table `images`
add `thumbnail` varchar(255);
create index `index_images_on_article_and_thumbnail` on images(article, thumbnail);
