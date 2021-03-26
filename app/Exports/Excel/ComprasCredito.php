<?php


namespace App\Exports\Excel;


use Illuminate\Contracts\View\View;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Maatwebsite\Excel\Concerns\Exportable;
use Maatwebsite\Excel\Concerns\FromView;

class ComprasCredito implements FromView
{
    use Exportable;

    private $data;
    private $tabla;
    private $fechaDesde;
    private $fechaHasta;
    private $codeProveedor;
    private $tipoPago;
    private $tipoComprobante;

    public function __construct($tabla,$fechaDesde,$fechaHasta,$codeProveedor,$tipoPago,$tipoComprobante)
    {

        $this->tabla = $tabla;
        $this->fechaDesde = $fechaDesde;
        $this->fechaHasta = $fechaHasta;
        $this->codeProveedor = $codeProveedor;
        $this->tipoPago = $tipoPago;
        $this->tipoComprobante = $tipoComprobante;
    }
    public function view(): View
    {
        $query =  DB::table('compra as com');
        if($this->tabla === 'credito') {
            $query->where('comTipoPago',$this->tabla);
        }
        if ($this->fechaDesde && $this->fechaHasta) {
            $query->whereBetween('comFecha', [$this->fechaDesde, $this->fechaHasta]);
        }
        if ($this->codeProveedor) {
            $query->where('idProveedor',$this->codeProveedor);
        }
        if ($this->tipoPago) {
            $query->where('comTipoPago',$this->tipoPago);
        }
        if ($this->tipoComprobante) {
            $query->where('comTipoComprobante',$this->tipoComprobante);
        }
        $query->join('persona as per', 'com.idProveedor', '=', 'per.id_persona')
            ->select('com.idCompra as idcompra', 'per.per_razon_social as proveedor',
                'per.per_ruc', 'com.comFecha as fecha', 'com.comEstado as estado',
                'com.comTipoPago as tipopago', 'com.comTipoComprobante as tipocomprobante',
                'com.comMontoPagado as efectivopagado', 'com.comMontoDeuda as efectivodeuda', 'com.comUrlComprobante as url',
                'com.comDescuento as descuento', 'com.comSubTotal as subtotal', 'com.comIgv as igv', 'com.comTotal as total');
        $result= $query->get();

        /*Log::info('err '.$result);*/
        return view('Exportar.Excel.ComprasCredito', [
            'compras' => $result
        ]);
    }
}
