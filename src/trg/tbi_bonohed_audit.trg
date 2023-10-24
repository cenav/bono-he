create or replace trigger tbi_procesobonohed_audit
  before insert
  on proceso_bonohe_d
  for each row
begin
  :new.create_user := user;
  :new.create_date := sysdate;
end;

