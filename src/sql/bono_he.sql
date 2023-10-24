select * from bono_he;

select *
  from vw_bono_he
 where ano = :anio
   and trimestre = 2;

select * from estado_proceso;

select * from periodo_mes;

select *
  from planilla10.parampla
 where num_pla = 947;

select *
  from planilla10.planilla
 where num_pla = 947
   and c_codigo = 'E567';

select *
  from planilla10.ingre_pla
 where num_pla = 947
   and c_codigo = 'E567';

select *
  from bono_he
 where id_periodo = 1;

select * from unidad_medida;

select to_char(sysdate, 'Q') as qtr from dual;

-- trimestre fecha inicio termino
  with trimestre as (
    select trunc(sysdate, 'Q') as d
      from dual
    )
select add_months(d, -3) as first, d - 1 as last
  from trimestre;


  with trimestre as (
    select trunc(sysdate, 'Q') as d
      from dual
    )
select to_number(to_char(d, 'Q')) as quarter
     , case
         when to_number(to_char(d, 'Q')) <= 2
           then 'first'
         else 'second'
       end as semester
  from trimestre;


-- fecha desde numero trim
  with rws as (
    select :anio as yr, 1 as qtr
      from dual
     union all
    select :anio as yr, 2 as qtr
      from dual
     union all
    select :anio as yr, 3 as qtr
      from dual
     union all
    select :anio as yr, 4 as qtr
      from dual
    )
     , qmths as (
     select level - 1 as q
       from dual
    connect by level <= 3
     )
select yr, qtr
     , add_months(to_date('01-01-' || yr, 'dd-mm-yyyy'), ((qtr - 1) * 3) + q) as st
     , add_months(to_date('01-01-' || yr, 'dd-mm-yyyy'), ((qtr - 1) * 3) + q + 1) - 1 as en
  from rws
       cross join qmths
 order by st;

-- fecha ini fin trimestre desde numero periodo
select add_months(to_date('01-01-' || :anio, 'dd-mm-yyyy'), ((:qtr - 1) * 3)) as st
     , add_months(to_date('01-01-' || :anio, 'dd-mm-yyyy'), ((:qtr - 1) * 3) + 3) - 1 as en
  from dual;

select *
  from cotizacion
 where fecha = to_date('29/08/2023', 'dd/mm/yyyy')
   and unidad_negocio in ('01', '02');


select c_codigo, count(c_codigo)
  from vw_bono_he
 where bono_logrado > 0
   and ano = 2023
having count(c_codigo) >= 2
 group by c_codigo;


  with marca_logrado as (
    select c_codigo, trimestre, bono_logrado
         , case when bono_logrado is not null and bono_logrado > 0 then 1 else 0 end as logrado
      from vw_bono_he
     where ano = 2023
       and c_codigo in ('E41311', 'E41316')
    )
     , marca_anterior as (
    select c_codigo, trimestre, bono_logrado, logrado
         , lag(logrado) over (partition by c_codigo order by trimestre) as anterior
      from marca_logrado
    )
     , prueba as (
    select c_codigo, trimestre, bono_logrado, logrado, anterior
         , case logrado when anterior then 1 end as tiempo_libre
      from marca_anterior
    )
select c_codigo, trimestre, bono_logrado, logrado, anterior, tiempo_libre
     , sum(case logrado when anterior then 1 end)
           over (partition by c_codigo order by trimestre asc rows between unbounded preceding and current row) as sum_tiempo_libre
  from prueba;


-- en base al proceso grabado
  with marca_logrado as (
    select d.id_empleado, p.periodo as trimestre, bono_logrado
         , case when bono_logrado is not null and bono_logrado > 0 then 1 else 0 end as logrado
      from proceso_bonohe p
           join proceso_bonohe_d d on p.id_proceso = d.id_proceso
     where p.anio = 2023
    )
     , marca_anterior as (
    select id_empleado, trimestre, bono_logrado, logrado
         , lag(logrado) over (partition by id_empleado order by trimestre) as anterior
      from marca_logrado
    )
     , muestra_acumulado as (
    select id_empleado, trimestre, bono_logrado, logrado, anterior
         , case logrado when anterior then 1 end as tiempo_libre
      from marca_anterior
    )
     , premio_logrado as (
    select id_empleado, trimestre, bono_logrado, logrado, anterior, tiempo_libre
         , sum(tiempo_libre)
               over (partition by id_empleado order by trimestre asc rows between unbounded preceding and current row) +
           1 as periodo_acum
      from muestra_acumulado
    )
select id_empleado, trimestre, l.periodo_acum, a.unidad_tiempo, a.premio_tiempo
  from premio_logrado l
       left join bono_he_acum a on l.periodo_acum = a.periodo_acum and a.id_periodo_mes = 'TT'
 where id_empleado = 'E4084';
--    and trimestre = 3;

select * from bono_he;

select * from bono_he_acum;


  with marca_logrado as (
    select d.id_empleado, p.periodo as trimestre, bono_logrado
         , case when bono_logrado is not null and bono_logrado > 0 then 1 else 0 end as logrado
      from proceso_bonohe p
           join proceso_bonohe_d d on p.id_proceso = d.id_proceso
     where p.anio = 2023
    )
     , marca_anterior as (
    select id_empleado, trimestre, bono_logrado, logrado
         , lag(logrado) over (partition by id_empleado order by trimestre) as anterior
      from marca_logrado
    )
     , muestra_acumulado as (
    select id_empleado, trimestre, bono_logrado, logrado, anterior
         , case when logrado = anterior and logrado > 0 then 1 end as tiempo_libre
      from marca_anterior
    )
select id_empleado, trimestre, bono_logrado, logrado, anterior, tiempo_libre
     , sum(tiempo_libre)
           over (partition by id_empleado order by trimestre asc rows between unbounded preceding and current row) +
       1 as periodo_acum
  from muestra_acumulado
 where id_empleado = 'E41316';


select *
  from planilla10.personal
 where c_codigo = 'E41316';


select *
  from asistencia.personal
 where cod_personal = 'E41316';


-- faltas, tardanzas
select *
  from asistencia.vw_resdiariodetallerenusa
 where fecha between to_date('21/07/2023', 'DD/MM/YYYY') and to_date('20/09/2023', 'DD/MM/YYYY')
   and dfalta > 0;


-- faltas
select *
  from asistencia.vw_resdiariodetallerenusa
 where fecha between to_date('21/07/2023', 'DD/MM/YYYY') and to_date('20/09/2023', 'DD/MM/YYYY')
   and dfalta > 0;

select min(fecha) from asistencia.vw_resdiariodetallerenusa;

select *
  from proceso_bonohe_d
 where id_empleado = 'E41311'
 order by id_proceso;

select *
  from asistencia.resumendiario
 where idconcepto = 343;

select count(fecha)
  from asistencia.resdetallado r
       join asistencia.personal p on r.idpersonal = p.idpersonal
 where idconcepto = 343
   and p.cod_personal = 'E567'
   and r.fecha between to_date('01/10/2023', 'dd/mm/yyyy') and to_date('31/10/2023', 'dd/mm/yyyy')
   and tiemporeal > 5
 order by fecha;

select *
  from asistencia.personal
 where cod_personal = 'E42931';

select *
  from asistencia.personal
 where idpersonal = 15682;

select *
  from asistencia.concepto
 where dsc_concepto like '%TARDANZA%';

-- 2 => dia
-- 1 => hora
select *
  from asistencia.concepto
 where dsc_concepto like '%FALTA%';

-- tardanza real
select *
  from asistencia.resdetallado
 where idpersonal = 15682
   and fecha > to_date('01/07/2023', 'DD/MM/YYYY')
   and idconcepto = 345
   and tiemporeal = 1;

select * from motivo_excluye;

select * from exclusiones;


select count(fecha) as veces
     , listagg(to_char(fecha, 'dd/mm/yyyy'), ' | ') within group ( order by fecha) as fechas
  from asistencia.resdetallado r
       join asistencia.personal p on r.idpersonal = p.idpersonal
       join asistencia.concepto c on r.idconcepto = c.idconcepto
 where r.idconcepto = 345
   and p.cod_personal = 'E42931'
   and r.fecha between '01072023' and '30092023'
   and ((c.unidad_tiempo = 1 and r.tiemporeal > 5) or
        (c.unidad_tiempo = 2 and r.tiemporeal = 1));
