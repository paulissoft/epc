--$NO_KEYWORD_EXPANSION$
REMARK
REMARK  $HeadURL$
REMARK

declare
  l_found pls_integer;
begin
  select  1
  into    l_found
  from    user_tables
  where   table_name = 'STD_OBJECTS';
exception
  when no_data_found
  then
    execute immediate 'create table std_objects (
  group_name varchar2(100)
, object_name varchar2(100)
, created_by varchar2(30)
, creation_date date
, last_updated_by varchar2(30)
, last_update_date date
, obj std_object
, constraint std_objects_pk primary key (group_name, object_name)
, constraint std_objects_chk1 check (created_by is not null)
, constraint std_objects_chk2 check (creation_date is not null)
, constraint std_objects_chk3 check (last_updated_by is not null)
, constraint std_objects_chk4 check (last_update_date is not null)
)
cache';
end;
/

@@epc_verify "std_objects" "table"
