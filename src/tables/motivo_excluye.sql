create table pevisa.motivo_excluye (
  id_excluye          varchar2(3),
  dsc_excluye         varchar2(50)            not null,
  id_concepto_tecflex number(6),
  regla               varchar2(1) default '+' not null
)
  tablespace pevisad;


create unique index pevisa.idx_motivo_excluye
  on pevisa.motivo_excluye(id_excluye)
  tablespace pevisax;


create or replace public synonym motivo_excluye for pevisa.motivo_excluye;


alter table pevisa.motivo_excluye
  add (
    constraint pk_motivo_excluye
      primary key (id_excluye)
        using index pevisa.idx_motivo_excluye
        enable validate
    );

alter table pevisa.motivo_excluye
  add (
    constraint chk_motivo_excluye_regla
      check ( regla in ('+', '-') )
    );

grant delete, insert, select, update on pevisa.motivo_excluye to sig_roles_invitado;

insert into pevisa.motivo_excluye ( id_excluye, dsc_excluye
                                  , id_concepto_tecflex)
values ('FAL', 'FALTA', 345);
insert into pevisa.motivo_excluye ( id_excluye, dsc_excluye
                                  , id_concepto_tecflex)
values ('VAC', 'VACACIONES', null);
insert into pevisa.motivo_excluye ( id_excluye, dsc_excluye
                                  , id_concepto_tecflex)
values ('TAR', 'TARDANZA', 343);
insert into pevisa.motivo_excluye ( id_excluye, dsc_excluye
                                  , id_concepto_tecflex)
values ('PER', 'PERMANENCIA', null);
