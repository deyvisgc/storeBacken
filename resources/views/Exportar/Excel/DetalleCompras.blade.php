<table style="width:100%;
	border-collapse:collapse;">

    <caption style="color: black; font-weight: bold; font-family: Arial,serif">Detalle de las compras {{$compras[0]->codecompra}}</caption>
    <thead>
    <tr>
        <th style="width: 5px; border:2px solid black">N#</th>
        <th style="width: 20px;border:2px solid black">Producto</th>
        <th style="width: 20px;border:2px solid black">Cantidad</th>
        <th style="width: 20px;border:2px solid black">Precio</th>
        <th style="width: 20px;border:2px solid black">Sub Total</th>
        <th style="width: 20px;border:2px solid black">Codigo Compra</th>
    </tr>
    </thead>
    <tbody>
    @foreach($compras as $com)
        <tr>
            <td style="">{{ $com->id}}</td>
            <td style="border:2px solid black">{{ $com->producto}}</td>
            <td style="border:2px solid black">{{ $com->cantidad}}</td>
            <td style="border:2px solid black">{{ $com->precio}}</td>
            <td style="border:2px solid black">{{ $com->subTotal }}</td>
            <td style="border:2px solid black">{{ $com->codecompra }}</td>
        </tr>
    @endforeach
    </tbody>
</table>
