drop index `index_features_columns_on_slug` on `features`;
alter table `features`
drop column `slug`;