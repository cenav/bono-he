drop table pevisa.bono_he_acum cascade constraints;

create table pevisa.bono_he_acum (
  id_periodo_mes varchar2(2),
  periodo_acum   number(3)   not null,
  unidad_tiempo  varchar2(4) not null,
  premio_tiempo  number(6)   not null
)
  tablespace pevisad;

create unique index pevisa.idx_bono_he_acum
  on pevisa.bono_he_acum(id_periodo_mes, periodo_acum)
  tablespace pevisax;

create or replace public synonym bono_he_acum for pevisa.bono_he_acum;

alter table pevisa.bono_he_acum
  add (
    constraint pk_bono_he_acum
      primary key (id_periodo_mes, periodo_acum)
        using index pevisa.idx_bono_he_acum
        enable validate
    );

alter table pevisa.bono_he_acum
  add (
    constraint fk_bonoheacum_periodomes
      foreign key (id_periodo_mes)
        references periodo_mes(id_periodo_mes),
    constraint fk_bonoheacum_unidadtiempo
      foreign key (unidad_tiempo)
        references unidad_medida(cod_unidad)
    );

grant delete, insert, select, update on pevisa.bono_he_acum to sig_roles_invitado;