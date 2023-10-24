create or replace trigger tbu_procesobonohed_audit
  before update
  on proceso_bonohe_d
  for each row
begin
  :new.update_user := user;
  :new.update_date := sysdate;
end;
