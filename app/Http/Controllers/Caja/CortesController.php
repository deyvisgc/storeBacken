<?php


namespace App\Http\Controllers\Caja;


use App\Http\Controllers\Controller;
use Core\CortesCaja\Infraestructura\Adapter\CreateCorteAdapter;
use Core\CortesCaja\Infraestructura\Adapter\ListCorteAdapter;
use Illuminate\Http\Request;

class CortesController extends Controller
{

    /**
     * @var CreateCorteAdapter
     */
    private CreateCorteAdapter $Createadapter;
    /**
     * @var ListCorteAdapter
     */
    private ListCorteAdapter $listCorteAdapter;

    public function __construct(CreateCorteAdapter $Createadapter, ListCorteAdapter $listCorteAdapter)
    {
        $this->Createadapter = $Createadapter;
        $this->listCorteAdapter = $listCorteAdapter;
        $this->middleware('auth');
    }
    function ObtenerSaldoInicial(int $idCaja) {
        return response()->json($this->listCorteAdapter->obtenerSaldoInicial($idCaja));
    }
    function SearhCortesXfechas(Request $request) {
        $fechaDesde = $request->fechaDesde;
        $fechaHasta = $request->fechaHasta;
        $idCaja = $request->idCaja;
        return response()->json($this->listCorteAdapter->buscarcortesxfechas($fechaDesde, $fechaHasta,$idCaja));

    }
    function GuardarCorteDiario(Request  $request) {
        return response()->json($this->Createadapter->GuardarCorte($request->detalleCorteCaja[0], $request->corteCaja,));

    }
    function GuardarCorteSemanal(Request  $request) {
        return response()->json($this->Createadapter->GuardarCorte($request->detalleCorteCaja, $request->corteCaja,));
    }
    function ddd(Request $request) {
        return response()->json($this->listCorteAdapter->obtenerTotalesCorte($request));

    }
}
