create or replace trigger tbu_procesobonohe_audit
  before update
  on proceso_bonohe
  for each row
begin
  :new.update_user := user;
  :new.update_date := sysdate;
end;
