create or replace package exclusion as

  type t_veces_concepto is record (
    veces  pls_integer,
    fechas varchar2(4000)
  );

  function veces_concepto_asistencia(
    p_concepto simple_integer
  , p_empleado varchar2
  , p_fch_ini  date
  , p_fch_fin  date
  ) return t_veces_concepto;

end exclusion;
