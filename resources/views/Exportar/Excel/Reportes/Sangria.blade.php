<?php
$fecha = date("Y-m-d");
?>
<table style="width:100%;
	border-collapse:collapse;">
    <thead>
    <tr>
        <th STYLE=" color: black; font-family: Arial; font-weight: bold; width: 100px" >Reporte de Sangria generada: {{$fecha}}</th></tr>
    <tr>
        <th style="width: 5px; border:2px solid black">Vendedor</th>
        <th style="width: 20px;border:2px solid black">Caja</th>
        <th style="width: 20px;border:2px solid black">Fecha</th>
        <th style="width: 20px;border:2px solid black">Tipo Sangria</th>
        <th style="width: 100px;border:2px solid black">Motivo</th>
        <th style="width: 20px;border:2px solid black">Monto</th>
    </tr>
    </thead>
    <tbody>
    @foreach($sangria[0] as $san)
        <tr>
            <td style="">{{ $san->per_nombre}}</td>
            <td style="border:2px solid black">{{ $san->ca_name}}</td>
            <td style="border:2px solid black">{{ $san->san_fecha}}</td>
            <td style="border:2px solid black">{{ $san->san_tipo_sangria}}</td>
            <td style="border:2px solid black">{{ $san->san_motivo}}</td>
            <td style="border:2px solid black">{{ $san->san_monto}}</td>
        </tr>
    @endforeach
    </tbody>
    <tfoot>
    <tr>
        <th colspan="5" class="text-right"> Total</th>
        <td>
            <span>S/</span>{{$sangria['total']}}
        </td>
    </tr>
    </tfoot>
</table>
