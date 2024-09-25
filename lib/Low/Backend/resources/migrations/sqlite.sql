-- 1 up
create table if not exists bundle (
  id       integer not null primary key,
  checksum text not null,
);
 
-- 1 down
drop table if exists bundle;