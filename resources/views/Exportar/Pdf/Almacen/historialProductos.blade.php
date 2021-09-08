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
    body {

    }
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
    table thead th {
        padding: 3px;
        position: sticky;
        top: 0;
        z-index: 1;
        width: 25vw;
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
                <th>Nombre Producto</th>
                <th>Fecha Vencimiento</th>
                <th>Fecha Creacíón</th>
                <th>Stock Antiguo</th>
                <th>Stock Nuevo</th>
                <th>Precio Compra Antiguo</th>
                <th>Precio Compra Nuevo</th>
                <th>Precio Venta Antiguo</th>
                <th>Precio Venta Nuevo</th>
                <th>Almacen</th>
                <th>Lote</th>
            </tr>
            </thead>
            <tbody>
            @foreach($historial as $pro)
                <tr>
                    <td>{{ $pro->pro_name}}</td>
                    <td>{{ $pro->fecha_vencimiento}}</td>
                    <td>{{ $pro->fecha_creacion}}</td>
                    <td>{{ $pro->stock_antiguo}}</td>
                    <td>{{ $pro->stock_nuevo}}</td>
                    <td>{{ $pro->precio_compra}}</td>
                    <td>{{ $pro->preciocompranuevo}}</td>
                    <td>{{ $pro->precio_venta}}</td>
                    <td>{{ $pro->precioventanuevo}}</td>
                    <td>{{ $pro->almacen}}</td>
                    <td>{{ $pro->lot_name}}</td>
                </tr>
            @endforeach
            </tbody>
        </table>
    </article>
</section>
</body>
</html>

