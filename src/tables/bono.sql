create table pevisa.bono (
  id_bono  number(3),
  dsc_bono varchar2(50)        not null,
  estado   number(1) default 1 not null
)
  tablespace pevisad;


create unique index pevisa.idx_bono
  on pevisa.bono(id_bono)
  tablespace pevisax;


create or replace public synonym bono for pevisa.bono;


alter table pevisa.bono
  add (
    constraint pk_bono
      primary key (id_bono)
        using index pevisa.idx_bono
        enable validate
    );


grant delete, insert, select, update on pevisa.bono to sig_roles_invitado;
