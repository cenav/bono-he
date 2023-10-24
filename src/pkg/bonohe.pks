create or replace package bonohe as

  procedure procesa(
    p_anio simple_integer
  , p_trim simple_integer
  );

  procedure elimina(
    p_anio simple_integer
  , p_trim simple_integer
  );

  procedure email(
    p_anio simple_integer
  , p_trim simple_integer
  );

--   procedure tarea(
--     p_ano simple_integer default extract(year from sysdate)
--   , p_mes simple_integer default extract(month from sysdate)
--   );

end bonohe;
