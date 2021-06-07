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
        <h4 style="text-align: center">HISTORIAL DE PRODUCTOS GENERADO EL : {{$fecha}}</h4>
        <table style="width:100%" id="customers">
            <thead>
            <tr>
                <th>Nombre</th>
                <th>Clase</th>
                <th>S.Clase</th>
                <th>U.Medida</th>
                <th>Codigo</th>
                <th>C.Barra</th>
                <th>F.Creacion</th>
            </tr>
            </thead>
            <tbody>
            @foreach($productos as $pro)
                <tr>
                    <td style="">{{ $pro->pro_name}}</td>
                    <td style="">{{ $pro->clasePadre}}</td>
                    <td style="">{{ $pro->classHijo}}</td>
                    <td style="">{{ $pro->unidad}}</td>
                    <td style="">{{ $pro->pro_code}}</td>
                    <td style="">{{ $pro->pro_cod_barra}}</td>
                    <td style="">{{ $pro->pro_fecha_creacion}}</td>
                </tr>
            @endforeach
            </tbody>
        </table>
    </article>
</section>
</body>
</html>

