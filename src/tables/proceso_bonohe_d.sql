drop table proceso_bonohe_d cascade constraints;

create table pevisa.proceso_bonohe_d (
  id_proceso        number(8),
  id_empleado       varchar2(8),
  nom_empleado      varchar2(50) not null,
  id_cargo          varchar2(6),
  dsc_cargo         varchar2(50),
  id_seccion        varchar2(6),
  dsc_seccion       varchar2(50),
  id_encargado      varchar2(4),
  nom_encargado     varchar2(50),
  mail_encargado    varchar2(50),
  he_100            number(8, 2),
  he_100_meta       number(8, 2),
  bono_logrado      number(8, 2),
  periodo_acumulado number(4),
  unidad_tiempo     varchar2(4),
  tiempo_logrado    number(6),
  tiempo_saldo      number(6),
  create_user       varchar2(30) not null,
  create_date       date         not null,
  update_user       varchar2(30),
  update_date       date
)
  tablespace pevisad;


create unique index pevisa.idx_procesobonohe_d
  on pevisa.proceso_bonohe_d(id_proceso, id_empleado)
  tablespace pevisax;

create index pevisa.idx_procesobonohed_empleado
  on pevisa.proceso_bonohe_d(id_empleado)
  tablespace pevisax;

create index pevisa.idx_procesobonohed_encargado
  on pevisa.proceso_bonohe_d(id_encargado)
  tablespace pevisax;

create index pevisa.idx_procesobonohed_seccion
  on pevisa.proceso_bonohe_d(id_seccion)
  tablespace pevisax;


create or replace public synonym proceso_bonohe_d for pevisa.proceso_bonohe_d;


alter table pevisa.proceso_bonohe_d
  add (
    constraint pk_procesobonohe_d
      primary key (id_proceso, id_empleado)
        using index pevisa.idx_procesobonohe_d
        enable validate,
    constraint fk_procesobonohe_d
      foreign key (id_proceso)
        references proceso_bonohe(id_proceso)
          on delete cascade,
    constraint fk_procesobonohe_undmed
      foreign key (unidad_tiempo)
        references unidad_medida(cod_unidad)
    );


grant delete, insert, select, update on pevisa.proceso_bonohe_d to sig_roles_invitado;
