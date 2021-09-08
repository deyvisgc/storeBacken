<?php
$fecha = date("Y-m-d");
?>
<table style="width:100%;
	border-collapse:collapse;">
    <thead>
    <tr>
        <td colspan="11" align="center" bgcolor="#48c774" style="color: white"><strong>Reporte de Historial del Producto del: {{$fecha}}</strong></td>
    </tr>
    <tr>
        <th style="width: 50px; border:2px solid black">Nombre Producto</th>
        <th style="width: 20px;border:2px solid black">Fecha Vencimiento</th>
        <th style="width: 20px;border:2px solid black">Fecha Creacíón</th>
        <th style="width: 20px;border:2px solid black">Stock Antiguo</th>
        <th style="width: 20px;border:2px solid black">Stock Nuevo</th>
        <th style="width: 20px;border:2px solid black">Precio Compra Antiguo</th>
        <th style="width: 20px;border:2px solid black">Precio Compra Nuevo</th>
        <th style="width: 20px;border:2px solid black">Precio Venta Antiguo</th>
        <th style="width: 20px;border:2px solid black">Precio Venta Nuevo</th>
        <th style="width: 20px;border:2px solid black">Almacen</th>
        <th style="width: 20px;border:2px solid black">Lote</th>
    </tr>
    </thead>
    <tbody>
    @foreach($historial as $pro)
        <tr>
            <td style="border:2px solid black">{{ $pro->pro_name}}</td>
            <td style="border:2px solid black">{{ $pro->fecha_vencimiento}}</td>
            <td style="border:2px solid black">{{ $pro->fecha_creacion}}</td>
            <td style="border:2px solid black">{{ $pro->stock_antiguo}}</td>
            <td style="border:2px solid black">{{ $pro->stock_nuevo}}</td>
            <td style="border:2px solid black">{{ $pro->precio_compra}}</td>
            <td style="border:2px solid black">{{ $pro->preciocompranuevo}}</td>
            <td style="border:2px solid black">{{ $pro->precio_venta}}</td>
            <td style="border:2px solid black">{{ $pro->precioventanuevo}}</td>
            <td style="border:2px solid black">{{ $pro->almacen}}</td>
            <td style="border:2px solid black">{{ $pro->lot_name}}</td>
        </tr>
    @endforeach
    </tbody>
</table>
