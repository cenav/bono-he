begin
  for i in 1..3 loop
    bonohe.procesa(2023, i);
  end loop;
  commit;
end;

begin
  for i in reverse 1..3 loop
    bonohe.elimina(2023, i);
  end loop;
  commit;
end;

declare
  l_veces exclusion.t_veces_concepto;
begin
  l_veces := exclusion.veces_concepto_asistencia(
      p_concepto => 345
    , p_empleado => 'E42931'
    , p_fch_ini => '01-07-2023'
    , p_fch_fin => '31-10-2023'
             );
  dbms_output.put_line(l_veces.veces);
  dbms_output.put_line(l_veces.fechas);
end;

select id_proceso, id_estado, fch_inicio, fch_termino, id_moneda, id_periodo_mes, anio, periodo
  from proceso_bonohe
 order by id_proceso;

select *
  from proceso_bonohe_d
 where id_empleado = 'E42731';

select *
  from proceso_bonohe_excluye
 where id_empleado = 'E42731'
 order by id_proceso;

select * from motivo_excluye;

select *
  from vw_personal
 where nombre like '%PASTRANA%';

select c_codigo, nombre, f_ingreso, trunc(months_between(sysdate, f_ingreso)) as meses
  from vw_personal
 where c_codigo in ('E1083', 'E1046', 'E42931');

select *
  from proceso_bonohe_excluye
 where exclusion = 1;

select *
  from proceso_bonohe_d
 where id_proceso = 3;

select *
  from periodo_mes
 where id_periodo_mes = 'TT';

select *
  from proceso_bonohe_d
 where id_proceso = 2
   and bono_logrado > 0;

select id_empleado, count(id_empleado)
  from proceso_bonohe_d
 where bono_logrado > 0
having count(id_empleado) >= 2
 group by id_empleado;

select *
  from proceso_bonohe_d
 where id_empleado = 'E41311'
 order by id_proceso;

select ano, c_codigo, nombre, c_cargo, desc_cargo, seccion, desc_seccion, c_encargado
     , desc_encargado, email_encargado, grupo, trimestre, inicio, final, he_100, he_100_meta
     , id_moneda, bono_logrado
  from vw_bono_he
 where ano = 2023
   and c_codigo = 'E41311';


select *
  from logger_logs
 order by id desc;


select * from proceso_bonohe_excluye;


  with excluye as (
    select e.id_proceso, e.id_empleado, sum(exclusion) as es_excluido
      from proceso_bonohe_excluye e
     group by e.id_proceso, e.id_empleado
    )
select d.id_proceso, p.fch_inicio, p.fch_termino, p.anio, p.periodo, d.id_empleado, nom_empleado
     , id_cargo, dsc_cargo, id_seccion, dsc_seccion, id_encargado, nom_encargado, mail_encargado
     , he_100, he_100_meta, bono_logrado, periodo_acumulado, unidad_tiempo, tiempo_logrado
     , tiempo_saldo, es_excluido
  from proceso_bonohe p
       join proceso_bonohe_d d on p.id_proceso = d.id_proceso
       join excluye e on d.id_proceso = e.id_proceso and d.id_empleado = e.id_empleado
 where d.id_empleado = 'E42731'
 order by d.id_proceso;

-- bono he trimestral
  with excluye as (
    select e.id_proceso, e.id_empleado, sum(exclusion) as es_excluido
      from proceso_bonohe_excluye e
     group by e.id_proceso, e.id_empleado
    )
select d.id_proceso, p.fch_inicio, p.fch_termino, p.anio, p.periodo, d.id_empleado, nom_empleado
     , dsc_cargo, dsc_seccion, nom_encargado, he_100, he_100_meta, bono_logrado, periodo_acumulado
     , unidad_tiempo, tiempo_logrado, tiempo_saldo
     , case when es_excluido >= 1 then 'SI' when es_excluido = 0 then 'NO' end as exclusion
  from proceso_bonohe p
       join proceso_bonohe_d d on p.id_proceso = d.id_proceso
       join excluye e on d.id_proceso = e.id_proceso and d.id_empleado = e.id_empleado
 order by 1, 2;

-- exclusiones
select id_proceso, id_empleado, m.dsc_excluye, medida, fijado, acumulado
     , case exclusion when 1 then 'SI' when 0 then 'NO' end as exclusion, fechas
  from proceso_bonohe_excluye e
       join motivo_excluye m on e.id_excluye = m.id_excluye
 order by 1, 2, 3;

