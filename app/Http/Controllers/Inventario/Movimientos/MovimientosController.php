<?php


namespace App\Http\Controllers\Inventario\Movimientos;


use App\Http\Controllers\Controller;
use App\Repository\Inventario\Movimientos\MovimientosRepositoryInterface;
use Illuminate\Http\Request;

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
        return response()->json($this->repository->all($request->params));
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
    public function exportar(Request $request) {
        return $this->repository->exportar($request);
    }
}
