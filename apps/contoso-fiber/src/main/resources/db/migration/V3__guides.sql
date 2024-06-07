create table support_guides(
    support_guide_id bigserial not null,
    description varchar(255) not null,
    name varchar(255) not null unique,
    url varchar(255) not null,
    primary key (support_guide_id)
);
