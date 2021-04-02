<?php
$fecha = date("Y-m-d");
?>
<table style="width:100%;
	border-collapse:collapse;">
    <thead>
    <tr>
        <th STYLE=" color: black; font-family: Arial; font-weight: bold; width: 100px" >Reporte de inventario generado: {{$fecha}}</th></tr>
    <tr>
        <th style="width: 5px; border:2px solid black">Codigo</th>
        <th style="width: 20px;border:2px solid black">Producto</th>
        <th style="width: 20px;border:2px solid black">Categoria</th>
        <th style="width: 20px;border:2px solid black">Existencia</th>
        <th style="width: 20px;border:2px solid black">Costo</th>
        <th style="width: 20px;border:2px solid black">Total</th>
    </tr>
    </thead>
    <tbody>
    @foreach($inventario[0] as $inv)
        <tr>
            <td style="">{{ $inv->pro_code}}</td>
            <td style="border:2px solid black">{{ $inv->pro_name}}</td>
            <td style="border:2px solid black">{{ $inv->clas_name}}</td>
            <td style="border:2px solid black">{{ $inv->pro_cantidad}}</td>
            <td style="border:2px solid black">{{ $inv->pro_precio_venta}}</td>
            <td style="border:2px solid black">{{ $inv->total}}</td>
        </tr>
    @endforeach
    </tbody>
    <tfoot>
    <tr>
        <th colspan="5" class="text-right"> Total</th>
        <td>
            <span>S/</span>{{$inventario['total']}}
        </td>
    </tr>
    </tfoot>
</table>
