<?php
$fecha = date("Y-m-d");
?>
<table style="width:100%;
	border-collapse:collapse;">
    <thead>
    <tr>
        <td colspan="22" align="center" bgcolor="#48c774" style="color: white"><strong>Reporte de Productos del: {{$fecha}}</strong></td>
    </tr>
    <tr>
        <th style="width: 50px; border:2px solid black">Nombre</th>
        <th style="width: 20px">Descripción</th>
        <th style="width: 20px">Marca</th>
        <th style="width: 20px;">Modelo</th>
        <th style="width: 20px;">Moneda</th>
        <th style="width: 20px;">Precio Compra</th>
        <th style="width: 20px;">Precio Venta</th>
        <th style="width: 20px;">Stock Inicial</th>
        <th style="width: 20px;">Stock Minimo</th>
        <th style="width: 10px">Incluye Descuento IGV</th>
        <th style="width: 10px">Incluye Descuendo Bolsa</th>
        <th style="width: 20px;">Fecha Creacion</th>
        <th style="width: 20px;">Fecha Vencimiento</th>
        <th style="width: 20px;">Codigo</th>
        <th style="width: 20px;">Codigo Barra</th>
        <th style="width: 20px;">Tipo Afectación</th>
        <th style="width: 20px;">Almacen</th>
        <th style="width: 20px;">Clase</th>
        <th style="width: 20px;">Sub Clase</th>
        <th style="width: 20px;">Unidad de Medida</th>
        <th style="width: 20px;">Lote</th>
        <th style="width: 20px;">Estado</th>
    </tr>
    </thead>
    <tbody>
    @foreach($productos as $pro)
        <tr>
            <td style="border:2px solid black">{{ $pro->pro_name}}</td>
            <td style="border:2px solid black">{{ $pro->pro_description}}</td>
            <td style="border:2px solid black">{{ $pro->pro_marca}}</td>
            <td style="border:2px solid black">{{ $pro->pro_modelo}}</td>
            <td style="border:2px solid black">{{ $pro->pro_moneda}}</td>
            <td style="border:2px solid black">{{ $pro->pro_precio_compra}}</td>
            <td style="border:2px solid black">{{ $pro->pro_precio_venta}}</td>
            <td style="border:2px solid black">{{ $pro->pro_stock_inicial}}</td>
            <td style="border:2px solid black">{{ $pro->pro_stock_minimo}}</td>
            @if($pro->incluye_igv== 1)
                <td style="border:2px solid black">SI</td>
            @else
                <td style="border:2px solid black">NO</td>
            @endif
            @if($pro->incluye_bolsa== 1)
                <td style="border:2px solid black">SI</td>
            @else
                <td style="border:2px solid black">NO</td>
            @endif
            <td style="border:2px solid black">{{ $pro->pro_fecha_creacion}}</td>
            <td style="border:2px solid black">{{ $pro->pro_fecha_vencimiento}}</td>
            <td style="border:2px solid black">{{ $pro->pro_code}}</td>
            <td style="border:2px solid black">{{ $pro->pro_cod_barra}}</td>
            <td style="border:2px solid black">{{ $pro->tipo_afectacion}}</td>
            <td style="border:2px solid black">{{ $pro->almacen}}</td>
            <td style="border:2px solid black">{{ $pro->clasePadre}}</td>
            <td style="border:2px solid black">{{ $pro->classHijo}}</td>
            <td style="border:2px solid black">{{ $pro->unidad}}</td>
            <td style="border:2px solid black">{{ $pro->lote}}</td>
            @if($pro->pro_status== 'active')
                <td style="border:2px solid black">Activo</td>
            @else
                <td style="border:2px solid black">Inactivo</td>
            @endif
        </tr>
    @endforeach
    </tbody>
</table>
