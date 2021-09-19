<?php


namespace App\Http\Controllers\Persona;


use App\Http\Controllers\Controller;
use App\Repository\Compras\ProveedorRepositoryInterface;
use App\Repository\Persona\TipoPersona\PersonaRepositoryInterface;
use Illuminate\Http\Request;

class TipoPersonaController extends Controller
{
    /**
     * @var PersonaRepositoryInterface
     */
    private PersonaRepositoryInterface $repository;

    public function __construct(PersonaRepositoryInterface $repository)
    {
        $this->repository = $repository;
        $this->middleware('auth');

    }
    public function getTipo(Request $request) {
        return response()->json($this->repository->getTypePersona($request));
    }
    public function find(Request $request) {
        return response()->json($this->repository->find($request));
    }
    function createPerson(Request $request) {
        return response()->json($this->repository->create($request->params));
    }
}
