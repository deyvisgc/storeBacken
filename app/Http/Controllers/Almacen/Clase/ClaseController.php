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
    // methodos para Categoria
    function editCategory($id){
        return response()->json($this->repository->show($id));
    }

    function selectCategoria (Request $request) {
        return response()->json($this->repository->selectCategoria($request));
    }

    function searchCategoria(Request $request) {
        return response()->json($this->repository->searchCategoria($request->params));
    }
    function deleteSubCategoria(int $id) {
        return response()->json($this->repository->delete($id));
    }

    // methodos para sub Categoria
    function editSubCategoria(Request $request) {
        return response()->json($this->repository->editSubCate($request));
    }
    function ObtenerSubCategorias(Request $request) {
        return response()->json($this->repository->selectSubCategoria($request));
    }
    function searchSubCate(Request $request) {
        return response()->json($this->repository->searchSubCate($request));
    }
    function delete(int $id) { // este metodo elimina una categoria o sub categoria
        return response()->json($this->repository->delete($id));
    }

    // methodos universales
    function getCategoria(Request $request)
    {
        // este metodo me trae las categorias y sub categorias
        return response()->json($this->repository->all($request));
    }
    function changeStatus(Request $request) { // este metodo actualiza el estado de una categoria o sub categoria
        return response()->json($this->repository->changeStatus($request->params));
    }
    function create(Request $request)
    { // este metodo es para crear o actulaizar una categoria o sub categoria
        return response()->json($this->repository->create($request['params']));
    }

}
