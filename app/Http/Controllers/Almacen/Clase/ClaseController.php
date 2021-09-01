<?php

namespace App\Http\Controllers\Almacen\Clase;

use App\Http\Controllers\Controller;
use App\Models\ClaseProduct;
use App\Repository\Almacen\Categorias\CategoriaRepository;
use Core\Almacen\Clase\Infraestructure\AdapterBridge\CreateBridge;
use Core\Almacen\Clase\Infraestructure\AdapterBridge\DeleteBridge;
use Core\Almacen\Clase\Infraestructure\AdapterBridge\ReadBridge;
use Core\Almacen\Clase\Infraestructure\AdapterBridge\UpdateBridge;
use Core\Traits\QueryTraits;
use Illuminate\Http\Request;

class ClaseController extends Controller
{
    use QueryTraits;

    /**
     * @var CategoriaRepository
     */
    private CategoriaRepository $repository;

    public function __construct(CategoriaRepository $repository)
    {
        $this->repository = $repository;
        $this->middleware('auth');
    }

    function getCategoria(Request $request)
    {
        return response()->json($this->repository->all($request));
    }
    function create(Request $request)
    {
        return response()->json($this->repository->create($request['params']));
    }
    function editCategory($id){
        return response()->json($this->repository->show($id));
    }
    function selectCategoria (Request $request) {
        return response()->json($this->repository->selectCategoria($request));
    }
    /*
    function searchCategoria(Request $request) {
        return response()->json($this->readBridge->searchCategoria($request->params));
    }
    function editCategoria(Request $request) {
        return response()->json($this->readBridge->editSubcate($request));
    }
    function ChangeStatusCate(Request $request) {
        return response()->json($this->updateBridge->ChangeStatusCate($request->data));
    }
    function ChangeStatusSubCate(Request $request) {
        return response()->json($this->updateBridge->ChangeStatusSubCate($request->data));
    }
    function ObtenerSubCategorias(Request $request) {
        return response()->json($this->Padreehijoclasexid($request));
    }
    */

}
