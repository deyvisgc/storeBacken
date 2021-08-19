<?php


namespace App\Http\Controllers\Persona;


use App\Http\Controllers\Controller;
use App\Repository\Compras\ProveedorRepositoryInterface;
use Illuminate\Http\Request;

class TipoPersonaController extends Controller
{
    /**
     * @var ProveedorRepositoryInterface
     */
    private ProveedorRepositoryInterface $repository;

    public function __construct(ProveedorRepositoryInterface $repository)
    {
        $this->repository = $repository;
        $this->middleware('auth');

    }

    public function find(Request $request) {
        return response()->json($this->repository->find($request));
    }
    function createPerson(Request $request) {
        return response()->json($this->repository->create($request->params));
    }
}
