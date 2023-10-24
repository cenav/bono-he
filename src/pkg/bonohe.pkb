create or replace package body bonohe as

  type periodo_acumulado_t is record (
    periodo_acum   proceso_bonohe_d.periodo_acumulado%type,
    unidad_tiempo  proceso_bonohe_d.unidad_tiempo%type,
    tiempo_logrado proceso_bonohe_d.tiempo_logrado%type
  );

--::::::::::::::::::::::::::::--
--      Private Routines      --
--::::::::::::::::::::::::::::--
  procedure registra_exclusion(
    p_idproceso  number
  , p_idempleado varchar2
  , p_idexcluye  varchar2
  , p_medida     varchar2
  , p_fijado     number
  , p_acumulado  number
  , p_fechas     varchar2
  , p_exclusion  signtype
  ) is
  begin
    insert into proceso_bonohe_excluye( id_proceso, id_empleado, id_excluye, medida
                                      , fijado, acumulado, fechas, exclusion)
    values ( p_idproceso, p_idempleado, p_idexcluye, p_medida
           , p_fijado, p_acumulado, p_fechas, p_exclusion);
  end;

  function es_excluido(
    p_regla     varchar2
  , p_fijado    number
  , p_acumulado number
  ) return signtype is
  begin
    return case p_regla
             when '+' then
               case when p_acumulado > p_fijado then 1 else 0 end
             when '-' then
               case when p_acumulado < p_fijado then 1 else 0 end
             else 0
           end;
  end;

  procedure por_jefatura(
    p_anio           simple_integer
  , p_trimestre      simple_integer
  , p_encargado_id   varchar2
  , p_encargado_nom  varchar2
  , p_encargado_mail varchar2
  ) is
    html clob;
    vars teplsql.t_assoc_array;
  begin
    html := q'[<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
    <html xmlns="http://www.w3.org/1999/xhtml">
    <head>
      <meta name="viewport" content="width=device-width"/>
      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
      <title>Pevisa Auto Parts</title>
      <style type="text/css">
                body {
                    margin: 0;
                    padding: 0;
                    min-width: 100%;
                    font-family: sans-serif;
                    background-color: #FFFFFF;
                }

                table {
                    margin: 0 0 10px 0;
                    padding: 0;
                    width: 100%;
                }

                div {
                    margin: 0;
                    padding: 0;
                }

                .header {
                    height: 40px;
                    text-align: center;
                    font-size: 20px;
                    font-weight: bold;
                    color: #808080;
                    text-decoration: underline;
                }

                .content {
                    height: 100px;
                    font-size: 16px;
                    line-height: 30px;
                }

                .footer {
                    height: 40px;
                    text-align: center;
                    font-size: 12px;
                    color: #999999;
                }

                .footer a {
                    color: #000000;
                    text-decoration: none;
                    font-style: normal;
                }

                .logo {
                    text-align: center;
                    font-style: italic;
                    color: #999999;
                }

                .myTable {
                    background-color: #eee;
                    border-collapse: collapse;
                    margin: 5px 0;
                }

                .myTable th {
                    background-color: #004899;
                    color: white;
                    font-weight: bold;
                }

                .myTable td, .myTable th {
                    padding: 5px;
                    border: 1px solid #b3b3b3;
                }

                .etiqueta {
                    font-weight: bold;
                }

                strong {
                    color: #85A8BA;
                }

      </style>
    </head>
    <body bgcolor="#FFFFFF">
    <div>
      <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td align="center" style="padding: 0 80px;">
            <div style="background-color: #eee;">
              <img src="https://drive.google.com/uc?id=1MBaDH_v72vVoaI-o9Ghbk18foq9wTQpt"
                   alt="logo pevisa">
            </div>
          </td>
        </tr>
        <tr class="header">
          <td style="padding: 1px 0 0 0;">
            <h2>Bono Horas Extras Trimestre ${trimestre}</h2>
          </td>
        </tr>
        <tr>
          <td style="padding: 20px 80px 0 80px;">
            <b>${encargado_nom}</b>, los siguientes trabajadores han llegado a su bono de horas extras:
          </td>
        </tr>
        <tr class="content">
          <td style="padding: 20px 80px;">
            <table class="myTable">
              <tr>
                <th>Codigo</th>
                <th>Nombre</th>
                <th>Seccion</th>
                <th>HE 100%</th>
                <th>Bono S/</th>
              </tr>
              <%
              for r in (
              select * from
              vw_bono_he
              where ano = '${ano}'
              and trimestre = '${trimestre}'
              and c_encargado = '${encargado_id}'
              and bono_logrado > 0
              order by nombre
              ) loop
              %>
              <tr>
                <td><%= r.c_codigo %></td>
                <td><%= r.nombre %></td>
                <td><%= r.desc_seccion %></td>
                <td><%= r.he_100 %></td>
                <td><%= r.bono_logrado %></td>
              </tr>
              <%
              end loop;
              %>
            </table>
          </td>
        </tr>
        <tr class="footer">
          <td style="padding: 40px;">
            <p>Usuario: ${usuario}</p>
            Envio de Correo Automático<br>
            Area de Sistemas
          </td>
        </tr>
      </table>
    </div>
    </body>
    </html>]';

    vars('ano') := p_anio;
    vars('trimestre') := p_trimestre;
    vars('encargado_id') := p_encargado_id;
    vars('encargado_nom') := p_encargado_nom;
    vars('usuario') := user;

    html := teplsql.render(vars, html);

    mail.send_html(
        p_to => p_encargado_mail || '; icatalan@pevisa.com.pe; jcabezas@pevisa.com.pe',
--         p_to => 'cnavarro@pevisa.com.pe',
        p_bcc => 'cnavarro@pevisa.com.pe',
        p_from => 'avisos_bienestar@pevisa.com.pe',
        p_subject => 'BONO HORAS EXTRAS TRIMESTRE ' || p_trimestre,
        p_html_msg => html
    );
  end;


--::::::::::::::::::::::::::::--
--      Public Routines       --
--::::::::::::::::::::::::::::--
  procedure email(
    p_anio simple_integer
  , p_trim simple_integer
  ) is
  begin
    for r in (
      select ano, trimestre, c_encargado, desc_encargado, email_encargado
        from vw_bono_he
       where ano = p_anio
         and trimestre = p_trim
         and bono_logrado > 0
       group by ano, trimestre, c_encargado, desc_encargado, email_encargado
      )
    loop
      por_jefatura(
          r.ano
        , r.trimestre
        , r.c_encargado
        , r.desc_encargado
        , r.email_encargado
      );
    end loop;
  end;


  procedure procesa(
    p_anio simple_integer
  , p_trim simple_integer
  ) is
    l_proceso proceso_bonohe%rowtype;

    cursor empleados_cr is
      select ano, c_codigo, nombre, c_cargo, desc_cargo, seccion, desc_seccion, c_encargado
           , desc_encargado, email_encargado, grupo, trimestre, inicio, final, he_100, he_100_meta
           , id_moneda, bono_logrado
        from vw_bono_he
       where ano = p_anio
         and trimestre = p_trim;

    function calcula_proceso return proceso_bonohe%rowtype is
      l_proceso proceso_bonohe%rowtype;
      l_meses   periodo_mes.meses%type;
    begin
      l_meses := api_periodo_mes.onerow('TT').meses;
      l_proceso.id_proceso := api_proceso_bonohe.next_key();
      l_proceso.id_estado := enum_estado_proceso.generado;
      l_proceso.fch_inicio :=
          add_months(to_date('01-01-' || p_anio, 'dd-mm-yyyy'), ((p_trim - 1) * l_meses));
      l_proceso.fch_termino := add_months(
                                   to_date('01-01-' || p_anio, 'dd-mm-yyyy')
                                 , ((p_trim - 1) * l_meses) + l_meses
                               ) - 1;
      l_proceso.id_moneda := enum_moneda.soles;
      l_proceso.id_periodo_mes := 'TT';
      l_proceso.anio := p_anio;
      l_proceso.periodo := p_trim;

      api_proceso_bonohe.ins(l_proceso);

      return l_proceso;
    end;


    procedure calcula_bono(
      p_empleado empleados_cr%rowtype
    , p_proceso  proceso_bonohe%rowtype
    ) is
      l_detalle proceso_bonohe_d%rowtype;
    begin
      l_detalle.id_proceso := p_proceso.id_proceso;
      l_detalle.id_empleado := p_empleado.c_codigo;
      l_detalle.nom_empleado := p_empleado.nombre;
      l_detalle.id_cargo := p_empleado.c_cargo;
      l_detalle.dsc_cargo := p_empleado.desc_cargo;
      l_detalle.id_seccion := p_empleado.seccion;
      l_detalle.dsc_seccion := p_empleado.desc_seccion;
      l_detalle.id_encargado := p_empleado.c_encargado;
      l_detalle.nom_encargado := p_empleado.desc_encargado;
      l_detalle.mail_encargado := p_empleado.email_encargado;
      l_detalle.he_100 := p_empleado.he_100;
      l_detalle.he_100_meta := p_empleado.he_100_meta;
      l_detalle.bono_logrado := p_empleado.bono_logrado;
      l_detalle.periodo_acumulado := null;
      l_detalle.unidad_tiempo := null;
      l_detalle.tiempo_logrado := null;
      l_detalle.tiempo_saldo := null;
      api_proceso_bonohe_d.ins(l_detalle);
    end;


    function periodo_acumulado(
      p_anio simple_integer
    , p_trim simple_integer
    , p_emp  varchar2
    ) return periodo_acumulado_t is
      l_acum periodo_acumulado_t;
    begin
        with marca_logrado as (
          select d.id_empleado, p.periodo as trimestre, bono_logrado
               , case
                   when bono_logrado is not null and bono_logrado > 0 then 1
                   else 0
                 end as logrado
            from proceso_bonohe p
                 join proceso_bonohe_d d on p.id_proceso = d.id_proceso
           where p.anio = p_anio
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
           , premio_logrado as (
          select id_empleado, trimestre, bono_logrado, logrado, anterior, tiempo_libre
               , sum(tiempo_libre)
                     over (partition by id_empleado order by trimestre asc rows between unbounded preceding and current row) +
                 1 as periodo_acum
            from muestra_acumulado
          )
      select l.periodo_acum, a.unidad_tiempo, a.premio_tiempo
        into l_acum
        from premio_logrado l
             left join bono_he_acum a on l.periodo_acum = a.periodo_acum and a.id_periodo_mes = 'TT'
       where id_empleado = p_emp
         and trimestre = p_trim;

      return l_acum;
    end;


    procedure calcula_tiempo(
      p_empleado empleados_cr%rowtype
    , p_proceso  proceso_bonohe%rowtype
    ) is
      l_detalle proceso_bonohe_d%rowtype;
      l_acum    periodo_acumulado_t;
    begin
      l_detalle := api_proceso_bonohe_d.onerow(p_proceso.id_proceso, p_empleado.c_codigo);
      l_acum := periodo_acumulado(p_proceso.anio, p_proceso.periodo, p_empleado.c_codigo);
      l_detalle.periodo_acumulado := l_acum.periodo_acum;
      l_detalle.unidad_tiempo := l_acum.unidad_tiempo;
      l_detalle.tiempo_logrado := l_acum.tiempo_logrado;
      l_detalle.tiempo_saldo := l_acum.tiempo_logrado;
      api_proceso_bonohe_d.upd(l_detalle);
    end;

    procedure calcula_exclusiones(
      p_empleado empleados_cr%rowtype
    , p_proceso  proceso_bonohe%rowtype
    ) is
      l_concepto          exclusion.t_veces_concepto;
      l_meses_permanencia number(5) := 0;
      l_fecha_ingreso     date;
      l_exclusion         signtype  := 0;
    begin
      for r in (
        select m.id_excluye, m.dsc_excluye, e.medida, e.cantidad, m.id_concepto_tecflex, m.regla
          from motivo_excluye m
               join exclusiones e on m.id_excluye = e.id_excluye
         where e.id_bono = 1 --> bono he trimestral
           and e.estado = 1 --> activo
        )
      loop
        case r.id_excluye
          when 'FAL' then
            l_concepto := exclusion.veces_concepto_asistencia(
                p_concepto => r.id_concepto_tecflex
              , p_empleado => p_empleado.c_codigo
              , p_fch_ini => p_proceso.fch_inicio
              , p_fch_fin => p_proceso.fch_termino
                          );
            l_exclusion := es_excluido(r.regla, r.cantidad, l_concepto.veces);
            registra_exclusion(p_proceso.id_proceso, p_empleado.c_codigo, r.id_excluye, r.medida,
                               r.cantidad, l_concepto.veces, l_concepto.fechas, l_exclusion);
          when 'PER' then
            l_fecha_ingreso := api_vw_personal.onerow(p_empleado.c_codigo).f_ingreso;
            l_meses_permanencia := trunc(months_between(sysdate, l_fecha_ingreso));
            l_exclusion := es_excluido(r.regla, r.cantidad, l_meses_permanencia);
            registra_exclusion(p_proceso.id_proceso, p_empleado.c_codigo, r.id_excluye, r.medida,
                               r.cantidad, l_meses_permanencia, null, l_exclusion);
        end case;
      end loop;
    end;

  begin
    l_proceso := calcula_proceso();
    for empleado in empleados_cr loop
      calcula_bono(empleado, l_proceso);
      calcula_tiempo(empleado, l_proceso);
      calcula_exclusiones(empleado, l_proceso);
    end loop;
  exception
    when others then
      /* Use the standard error logging mechanism. */
      if sqlcode not between -20999 and -20000 then
        logger.log_error('Informacion del error aqui');
      end if;

      rollback;
      raise;
  end;


  procedure elimina(
    p_anio simple_integer
  , p_trim simple_integer
  ) is
  begin
    delete from proceso_bonohe where anio = p_anio and periodo = p_trim;
  end;

end bonohe;
/
