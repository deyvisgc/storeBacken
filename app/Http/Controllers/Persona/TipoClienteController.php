<?php


namespace App\Http\Controllers\Persona;


use App\Http\Controllers\Controller;
use App\Repository\Persona\TipoPersona\TipoClienteRepository;
use Illuminate\Http\Request;

class TipoClienteController extends Controller
{
    private TipoClienteRepository $repository;

    public function __construct(TipoClienteRepository $repository)
    {
        $this->repository = $repository;
        $this->middleware('auth');

    }
    function getTipo(Request $request) {
        return response()->json($this->repository->all($request));
    }
    function getTipoXid(int $id) {
        return response()->json($this->repository->show($id));
    }
    function create(Request $request) {
        return response()->json($this->repository->create($request->params));
    }
    function delete(int $id) {
        return response()->json($this->repository->delete($id));
    }
    function changeStatus(Request $request) {
        return response()->json($this->repository->changeStatus($request->params));

    }
}
