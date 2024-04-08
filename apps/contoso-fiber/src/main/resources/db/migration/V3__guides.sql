create table support_guides(
    activity_type_id bigserial not null,
    description varchar(255) not null,
    name varchar(255) not null,
    url varchar(255) not null,
    primary key (activity_type_id)
);

-- Sample Data
insert into support_guides(activity_type_id, description, name, url) values (1, 'Instructions on how to reset your password', 'How to reset your password', 'https://www.contoso.com/password-reset.pdf');
insert into support_guides(activity_type_id, description, name, url) values (2, 'Instructions on how to create a support ticket', 'How to open a support case', 'https://www.contoso.com/support-case.pdf');
