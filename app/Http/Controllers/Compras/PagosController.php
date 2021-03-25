<?php


namespace App\Http\Controllers\Compras;


use App\Http\Controllers\Controller;
use Core\Compras\Infraestructure\Adapter_Bridge\PagosBridge;
use Illuminate\Http\Request;

class PagosController extends Controller
{
    /**
     * @var PagosBridge
     */
    private PagosBridge $pagosBridge;

    public function __construct(PagosBridge $pagosBridge)
    {
        $this->pagosBridge = $pagosBridge;
    }

    public function PagosCredito(Request $request) {
        return  response()->json($this->pagosBridge->__Pagos($request->data));
    }
}
