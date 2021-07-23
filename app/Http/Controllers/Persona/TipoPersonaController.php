<?php


namespace App\Http\Controllers\Persona;


use App\Http\Controllers\Controller;
use App\Repository\Compras\ComprasRepositoryInterface;
use Illuminate\Http\Request;

class TipoPersonaController extends Controller
{
    /**
     * @var ComprasRepositoryInterface
     */
    private ComprasRepositoryInterface $repository;

    public function __construct(ComprasRepositoryInterface $repository)
    {
        $this->repository = $repository;
    }

    public function find(Request $request) {
        return $this->repository->find($request->numeroDocumento);
    }
}
