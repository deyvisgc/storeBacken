<table style="width:100%;
	border-collapse:collapse;">
    <thead>
    <tr style="margin-left: 1000%;"><th STYLE=" color: black; font-family: Arial; font-weight: bold" >INFORMACION DE LA COMPRA</th></tr>
    <tr>
        <th style="width: 5px; border:2px solid black">N# Compra</th>
        <th style="width: 20px;border:2px solid black">Proveedor</th>
        <th style="width: 20px;border:2px solid black">Ruc</th>
        <th style="width: 20px;border:2px solid black">Fecha</th>
        <th style="width: 20px;border:2px solid black">Estado</th>
        <th style="width: 20px;border:2px solid black">Tipo Pago</th>
        <th style="width: 20px;border:2px solid black">Tipo Comprobante</th>
        <th style="width: 20px;border:2px solid black">Efectivo PAGADO</th>
        <th style="width: 20px;border:2px solid black">Efectivo DEUDA</th>
        <th style="width: 20px; border:2px solid black">Url Comprobante</th>
        <th style="width: 20px; border:2px solid black">Descuento</th>
        <th style="width: 20px; border:2px solid black">Sub total </th>
        <th style="width: 20px; border:2px solid black">Igv</th>
        <th style="width: 20px; border:2px solid black">Total</th>
    </tr>
    </thead>
    <tbody>
    @foreach($compras as $com)
        <tr>
            <td style="">{{ $com->idcompra}}</td>
            <td style="border:2px solid black">{{ $com->proveedor}}</td>
            <td style="border:2px solid black">{{ $com->per_ruc}}</td>
            <td style="border:2px solid black">{{ $com->fecha}}</td>
            @if($com->estado== '1')
                <td style="border:2px solid black">Debe</td>
            @else
                <td style="border:2px solid black">Pagada</td>
            @endif
            <td style="border:2px solid black">{{ $com->tipopago }}</td>
            <td style="border:2px solid black">{{ $com->tipocomprobante }}</td>
            <td style="border:2px solid black">{{ $com->efectivopagado }}</td>
            <td style="border:2px solid black">{{ $com->efectivodeuda }}</td>
            <td style="border:2px solid black">{{ $com->url }}</td>
            <td style="border:2px solid black">{{ $com->descuento }}</td>
            <td style="border:2px solid black">{{ $com->subtotal }}</td>
            <td style="border:2px solid black">{{ $com->igv }}</td>
            <td style="border:2px solid black">{{ $com->total }}</td>
        </tr>
    @endforeach
    </tbody>
</table>
