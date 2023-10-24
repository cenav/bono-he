create table pevisa.exclusiones (
  id_bono    number(3),
  id_excluye varchar2(3),
  medida     varchar2(30)        not null,
  cantidad   number(5)           not null,
  estado     number(1) default 1 not null
)
  tablespace pevisad;


create unique index pevisa.idx_exclusiones
  on pevisa.exclusiones(id_bono, id_excluye)
  tablespace pevisax;


create or replace public synonym exclusiones for pevisa.exclusiones;


alter table pevisa.exclusiones
  add (
    constraint pk_exclusiones
      primary key (id_bono, id_excluye)
        using index pevisa.idx_exclusiones
        enable validate
    );

alter table pevisa.exclusiones
  add (
    constraint fk_exclusiones_bono
      foreign key (id_bono)
        references bono(id_bono)
          enable validate,
    constraint fk_exclusiones_motivo
      foreign key (id_excluye)
        references motivo_excluye(id_excluye)
          enable validate
    );


grant delete, insert, select, update on pevisa.exclusiones to sig_roles_invitado;
