create or replace package api_proceso_bonohe_d is
  type aat is table of proceso_bonohe_d%rowtype index by pls_integer;
  type ntt is table of proceso_bonohe_d%rowtype;

  procedure ins(
    p_rec in proceso_bonohe_d%rowtype
  );

  procedure ins(
    p_coll aat
  );

  procedure upd(
    p_rec in proceso_bonohe_d%rowtype
  );

  procedure upd(
    p_coll aat
  );

  procedure del(
    p_id_proceso in  proceso_bonohe_d.id_proceso%type
  , p_id_empleado in proceso_bonohe_d.id_empleado%type
  );

  function onerow(
    p_id_proceso in  proceso_bonohe_d.id_proceso%type
  , p_id_empleado in proceso_bonohe_d.id_empleado%type
  ) return proceso_bonohe_d%rowtype result_cache;

  function allrows return aat;

  function exist(
    p_id_proceso in  proceso_bonohe_d.id_proceso%type
  , p_id_empleado in proceso_bonohe_d.id_empleado%type
  ) return boolean;
end;


create or replace package body api_proceso_bonohe_d is
  forall_err exception;
  pragma exception_init (forall_err, -24381);

  procedure ins(
    p_rec in proceso_bonohe_d%rowtype
  ) is
  begin
    insert into proceso_bonohe_d
    values p_rec;
  end;

  procedure ins(
    p_coll in aat
  ) is
  begin
    forall i in 1 .. p_coll.count save exceptions
      insert into proceso_bonohe_d values p_coll(i);
  exception
    when forall_err then
      for i in 1 .. sql%bulk_exceptions.COUNT loop
        logger.log('PK: ' || p_coll(sql%bulk_exceptions(i).error_index).id_proceso ||
                   ' Err: ' || sqlerrm(sql%bulk_exceptions(i).error_code * -1));
      end loop;
      raise;
  end;

  procedure upd(
    p_rec in proceso_bonohe_d%rowtype
  ) is
  begin
    update proceso_bonohe_d t
       set row = p_rec
     where t.id_proceso = p_rec.id_proceso
       and t.id_empleado = p_rec.id_empleado;
  end;

  procedure upd(
    p_coll in aat
  ) is
  begin
    forall i in 1 .. p_coll.count save exceptions
      update proceso_bonohe_d
         set row = p_coll(i)
       where id_proceso = p_coll(i).id_proceso
         and id_empleado = p_coll(i).id_empleado;
  exception
    when forall_err then
      for i in 1 .. sql%bulk_exceptions.COUNT loop
        logger.log('PK: ' || p_coll(sql%bulk_exceptions(i).error_index).id_proceso ||
                   ' Err: ' || sqlerrm(sql%bulk_exceptions(i).error_code * -1));
      end loop;
      raise;
  end;

  procedure del(
    p_id_proceso in  proceso_bonohe_d.id_proceso%type
  , p_id_empleado in proceso_bonohe_d.id_empleado%type
  ) is
  begin
    delete
      from proceso_bonohe_d t
     where t.id_proceso = p_id_proceso
       and t.id_empleado = p_id_empleado;
  end;

  function onerow(
    p_id_proceso in  proceso_bonohe_d.id_proceso%type
  , p_id_empleado in proceso_bonohe_d.id_empleado%type
  ) return proceso_bonohe_d%rowtype result_cache is
    rec proceso_bonohe_d%rowtype;
  begin
    select *
      into rec
      from proceso_bonohe_d t
     where t.id_proceso = p_id_proceso
       and t.id_empleado = p_id_empleado;

    return rec;
  exception
    when no_data_found then
      return null;
    when too_many_rows then
      raise;
  end;

  function allrows return aat is
    p_coll aat;
  begin
    select * bulk collect
      into p_coll
      from proceso_bonohe_d;

    return p_coll;
  end;

  function exist(
    p_id_proceso in  proceso_bonohe_d.id_proceso%type
  , p_id_empleado in proceso_bonohe_d.id_empleado%type
  ) return boolean is
    dummy pls_integer;
  begin
    select 1
      into dummy
      from proceso_bonohe_d t
     where t.id_proceso = p_id_proceso
       and t.id_empleado = p_id_empleado;

    return true;
  exception
    when no_data_found then
      return false;
    when too_many_rows then
      return true;
  end;

end;
