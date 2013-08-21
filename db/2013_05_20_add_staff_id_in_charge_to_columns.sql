alter table `columns`
add `staff_id_in_charge` int(11) NOT NULL DEFAULT 0;

create index `index_staff_id_in_charge_on_columns` on columns(staff_id_in_charge);
