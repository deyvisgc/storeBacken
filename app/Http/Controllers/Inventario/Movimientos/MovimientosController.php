<?php


namespace App\Http\Controllers\Inventario\Movimientos;


use App\Http\Controllers\Controller;
use App\Repository\Inventario\Movimientos\Entity\dtoRetiroStockAlmacen;
use App\Repository\Inventario\Movimientos\MovimientosRepositoryInterface;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class MovimientosController extends Controller
{
    private MovimientosRepositoryInterface $repository;

    public function __construct(MovimientosRepositoryInterface  $repository)
    {
        $this->repository = $repository;
        $this->middleware('auth', ['except' => [
            'Exportar'
        ]]);
    }
    function getMovimiento(Request $request) {
        return response()->json($this->repository->all($request));
    }
    function getMovimientoXid(int $id) {
        return response()->json($this->repository->show($id));
    }
    function getRepocision(Request $request) {
        return response()->json($this->repository->getRepocision($request));
    }
    function ajustarStock(Request $request) {
        return response()->json($this->repository->ajustarStock($request->params));
    }
    function traslado(Request  $request) {
        return response()->json($this->repository->create($request->params));
    }
    function trasladoMultiple(Request  $request) {
        return response()->json($this->repository->trasladoMultiple($request->params));
    }
    function removeStock(Request  $request) {
        $params = $request->params;
        $remover = new dtoRetiroStockAlmacen($params['id'],$params['id_producto'],$params['id_almacen'], $params['stockActual'], $params['cantidadRetirar'], $params['motivoRetiro'], Auth::user()->us_usuario);
        return response()->json($this->repository->removeStock($remover));
    }
    function obtenerStock(Request $request) {
        return response()->json($this->repository->obtenerStock($request));
    }
    public function exportar(Request $request) {
        return $this->repository->exportar($request);
    }
}
