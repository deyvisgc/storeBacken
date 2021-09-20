<?php
$fecha = date("Y-m-d");
?><!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="title" content="Título de la WEB">
    <meta name="description" content="Descripción de la WEB">
</head>
<style>
.header {
    width: 90%;
}
.box {
    display: inline-block;
    height: 50px;
}
#customers {
    font-family: Arial, Helvetica, sans-serif;
    border-collapse: collapse;
    width: 100%;
}

#customers td, #customers th {
    padding: 8px;
}

#customers tr:nth-child(even){background-color: #f2f2f2;}

#customers th {
    padding-top: 12px;
    padding-bottom: 12px;
    text-align: left;
    background-color: #04AA6D;
    color: white;
}
</style>
<body>
<header class="header">
    <div class="box" style="width: 5%;"><img src="{{base_path('public/descarga.png')}}" alt="Girl in a jacket" width="100" height="100"></div>
    <div class="box" style="width: 85%;"></div>
    <div class="box">Fecha: {{$fecha}}</div>
</header><br><br><br>
<section style="width: 100%;">
    <article>
        <h4 style="text-align: center">Historial dE {{$titulo}} generado el : {{$fecha}}</h4>
        <table style="width:100%" id="customers">
            <thead>
              <tr>
                <th>Nombre / Razon Social</th>
                <th>Tipo Documento</th>
                <th>Número Documento</th>
                <th>Codigo Interno</th>
                <th>Tipo Cliente</th>
                <th>Telefono</th>
                <th>Email</th>
                <th>Dirección</th>
              </tr>
            </thead>
            <tbody>
            @foreach($cliente as $cli)
                <tr>
                    <td>{{ $cli->per_nombre}}</td>
                    <td>{{ $cli->per_tipo_documento}}</td>
                    <td>{{ $cli->per_numero_documento}}</td>
                    <td>{{ $cli->per_codigo_interno}}</td>
                    <td>{{ $cli->descripcion}}</td>
                    <td>{{ $cli->per_celular}}</td>
                    <td>{{ $cli->per_email}}</td>
                    <td>{{ $cli->per_direccion}}</td>
                </tr>
            @endforeach
            </tbody>
        </table>
    </article>
</section>
</body>
</html>

