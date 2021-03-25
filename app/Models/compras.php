<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class compras extends Model
{
    protected $table = 'compra';
    protected $primaryKey = 'idCompra';
    public $timestamps = false;
    protected $fillable = [
        'idProveedor', 'comFecha','comTipoComprobante','comSerieCorrelativo','comTipoPago',
        'comUrlComprobante', 'comDescuento','comEstado', 'comSubTotal', 'comTotal','comIgv',
        'comMontoPagado', 'comMontoDeuda', 'com_cuotas'
    ];
}
