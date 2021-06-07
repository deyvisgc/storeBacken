<?php
$fecha = date("Y-m-d");
?>
<table style="width:100%;
	border-collapse:collapse;">
    <thead>
    <tr>
        <th STYLE=" color: black; font-family: Arial; font-weight: bold; width: 100px" >Reporte de Productos del: {{$fecha}}</th></tr>
    <tr>
        <th style="width: 5px; border:2px solid black">Nombre</th>
        <th style="width: 20px;border:2px solid black">Clase</th>
        <th style="width: 20px;border:2px solid black">Sub Clase</th>
        <th style="width: 20px;border:2px solid black">Unidad de Medida</th>
        <th style="width: 20px;border:2px solid black">Codigo</th>
        <th style="width: 20px;border:2px solid black">Codigo Barra</th>
        <th style="width: 20px;border:2px solid black">Fecha Creacion</th>
        <th style="width: 20px;border:2px solid black">Descripcion</th>
        <th style="width: 20px;border:2px solid black">Estado</th>
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
            <td style="">{{ $pro->pro_description}}</td>
            @if($pro->pro_status== 'active')
                <td style="border:2px solid black">Activo</td>
            @else
                <td style="border:2px solid black">Inactivo</td>
            @endif
        </tr>
    @endforeach
    </tbody>
</table>
