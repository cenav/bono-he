-- create view vw_bono_he as
  with horas_trimestre as (
    select extract(year from p.f_inicio) as ano, i.c_codigo, e.nombre, e.desc_cargo, e.desc_seccion
         , e.c_encargado, e.desc_encargado, e.email_encargado, s.descripcion as grupo
         , to_char(p.f_inicio, 'q') as trimestre
         , sum(i.valor_ori) as he_100
         , min(p.f_inicio) as inicio
         , max(p.f_final) as final
      from planilla10.ingre_pla i
           join planilla10.parampla p on i.num_pla = p.num_pla
           join vw_personal e on i.c_codigo = e.c_codigo
           join planilla10.t_sector s on e.sector = s.c_sector
     where c_concepto = '1013' --> horas extras 100%
       and p.tipo_pla = 'N'    --> planilla normal
       and e.sector = '40'     --> solo planta
     group by extract(year from p.f_inicio), i.c_codigo, to_char(p.f_inicio, 'q')
            , s.descripcion, e.nombre, e.desc_cargo, e.desc_seccion, e.desc_encargado
            , e.email_encargado
            , e.c_encargado
     order by ano, c_codigo, trimestre
    )
     , rangos as (
    select id_periodo, id_rango as rango_del
         , nvl(lead(id_rango - 1) over (partition by id_periodo_mes, id_periodo order by id_rango),
               9999) as rango_al
         , id_moneda, bono
      from bono_he
     where id_periodo_mes = 'TT'
     order by id_periodo_mes, id_periodo, id_rango
    )
select ht.ano, ht.c_codigo, ht.nombre, ht.desc_cargo, ht.desc_seccion, ht.c_encargado
     , ht.desc_encargado
     , ht.email_encargado, ht.grupo, ht.trimestre, ht.inicio, ht.final, ht.he_100
     , bh.rango_del as he_100_meta
     , bh.id_moneda, bh.bono as bono_logrado
     , lag(bh.bono, 1) over (order by ht.trimestre) as acumulado
  from horas_trimestre ht
       join rangos bh
            on ht.trimestre = bh.id_periodo and ht.he_100 between bh.rango_del and bh.rango_al
 where ht.ano = 2022
   and ht.c_codigo = 'E41311';
