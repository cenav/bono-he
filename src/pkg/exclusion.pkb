create or replace package body exclusion as

  function veces_concepto_asistencia(
    p_concepto simple_integer
  , p_empleado varchar2
  , p_fch_ini  date
  , p_fch_fin  date
  ) return t_veces_concepto is
    l_veces t_veces_concepto;
  begin
    select count(fecha) as veces
         , listagg(to_char(fecha, 'dd/mm/yyyy'), ' | ') within group ( order by fecha) as fechas
      into l_veces
      from asistencia.resdetallado r
           join asistencia.personal p on r.idpersonal = p.idpersonal
           join asistencia.concepto c on r.idconcepto = c.idconcepto
     where r.idconcepto = p_concepto
       and p.cod_personal = p_empleado
       and r.fecha between p_fch_ini and p_fch_fin
       and ((c.unidad_tiempo = 1 and r.tiemporeal > 5) or
            (c.unidad_tiempo = 2 and r.tiemporeal = 1));

    return l_veces;
  exception
    when no_data_found then return null;
    when too_many_rows then raise;
  end;

end exclusion;
