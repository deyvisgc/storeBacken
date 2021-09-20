<?php
$fecha = date("Y-m-d");
?>
<table style="width:100%;
	border-collapse:collapse;">
    <thead>
    <tr>
        <td colspan="16" align="center" bgcolor="#48c774" style="color: white"><strong>Reporte de {{$titulo}} del: {{$fecha}}</strong></td>
    </tr>
    <tr>
        <th style="width: 10px; border:2px solid black">Nro</th>
        <th style="width: 50px; border:2px solid black">Nombre</th>
        <th style="width: 50px; border:2px solid black">Razón Social</th>
        <th style="width: 20px;border:2px solid black">Tipo Documento</th>
        <th style="width: 20px;border:2px solid black">Número Documento</th>
        <th style="width: 20px;border:2px solid black">Fecha Creación</th>
        <th style="width: 20px;border:2px solid black">Codigo Interno</th>
        <th style="width: 20px;border:2px solid black">Tipo Cliente</th>
        <th style="width: 20px;border:2px solid black">Departamento</th>
        <th style="width: 20px;border:2px solid black">Provincia</th>
        <th style="width: 20px;border:2px solid black">Distrito</th>
        <th style="width: 30px;border:2px solid black">Dirección</th>
        <th style="width: 20px;border:2px solid black">Telefono</th>
        <th style="width: 20px;border:2px solid black">Email</th>
        <th style="width: 20px;border:2px solid black">Tipo Usuario</th>
        <th style="width: 20px;border:2px solid black">Estado</th>
    </tr>
    </thead>
    <tbody>
    @foreach($cliente as $cli)
        <tr>
            <td style="border:2px solid black">{{ $cli->id_persona}}</td>
            <td style="border:2px solid black">{{ $cli->per_nombre}}</td>
            <td style="border:2px solid black">{{ $cli->per_razon_social}}</td>
            <td style="border:2px solid black">{{ $cli->per_tipo_documento}}</td>
            <td style="border:2px solid black">{{ $cli->per_numero_documento}}</td>
            <td style="border:2px solid black">{{ $cli->per_fecha_creacion}}</td>
            <td style="border:2px solid black">{{ $cli->per_codigo_interno}}</td>
            <td style="border:2px solid black">{{ $cli->descripcion}}</td>
            <td style="border:2px solid black">{{ $cli->departamento}}</td>
            <td style="border:2px solid black">{{ $cli->provincia}}</td>
            <td style="border:2px solid black">{{ $cli->distrito}}</td>
            <td style="border:2px solid black">{{ $cli->per_direccion}}</td>
            <td style="border:2px solid black">{{ $cli->per_celular}}</td>
            <td style="border:2px solid black">{{ $cli->per_email}}</td>
            <td style="border:2px solid black">{{ $cli->per_tipo}}</td>
            @if($cli->per_status == 'active')
                <td style="border:2px solid black">Activo</td>
            @else
                <td style="border:2px solid black">Inactivo</td>
            @endif
        </tr>
    @endforeach
    </tbody>
</table>
