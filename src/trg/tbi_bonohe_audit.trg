create or replace trigger tbi_procesobonohe_audit
  before insert
  on proceso_bonohe
  for each row
begin
  :new.create_user := user;
  :new.create_date := sysdate;
end;

