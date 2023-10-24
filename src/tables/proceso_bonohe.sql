drop table pevisa.proceso_bonohe cascade constraints;

create table pevisa.proceso_bonohe (
  id_proceso     number(8),
  id_estado      number(2)    not null,
  fch_inicio     date         not null,
  fch_termino    date         not null,
  id_moneda      varchar2(2)  not null,
  id_periodo_mes varchar2(2)  not null,
  anio           number(4)    not null,
  periodo        number(2)    not null,
  create_user    varchar2(30) not null,
  create_date    date         not null,
  update_user    varchar2(30),
  update_date    date
)
  tablespace pevisad;

create unique index pevisa.idx_procesobonohe
  on pevisa.proceso_bonohe(id_proceso)
  tablespace pevisax;

create index pevisa.idx_procesobonohe_estado
  on pevisa.proceso_bonohe(id_estado)
  tablespace pevisax;

create index pevisa.idx_procesobonohe_periodo
  on pevisa.proceso_bonohe(anio, periodo)
  tablespace pevisax;

create or replace public synonym proceso_bonohe for pevisa.proceso_bonohe;

alter table pevisa.proceso_bonohe
  add (
    constraint pk_procesobonohe
      primary key (id_proceso)
        using index pevisa.idx_procesobonohe
        enable validate
    , constraint fk_procesobonohe_estado
      foreign key (id_estado)
        references estado_proceso(id_estado)
    , constraint fk_procesobonohe_moneda
      foreign key (id_moneda)
        references moneda(id_moneda)
    , constraint fk_procesobonohe_periodomes
      foreign key (id_periodo_mes)
        references periodo_mes(id_periodo_mes)
    );

alter table proceso_bonohe
  add constraint uq_procesobonohe_periodo
    unique (anio, periodo);

grant delete, insert, select, update on pevisa.proceso_bonohe to sig_roles_invitado;
