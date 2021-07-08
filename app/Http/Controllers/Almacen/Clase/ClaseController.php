<?php

namespace App\Http\Controllers\Almacen\Clase;

use App\Http\Controllers\Controller;
use App\Models\ClaseProduct;
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
     * @var CreateBridge
     */
    private CreateBridge $createBridge;
    /**
     * @var UpdateBridge
     */
    private UpdateBridge $updateBridge;

    /**
     * @var ReadBridge
     */
    private ReadBridge $readBridge;
    /**
     * @var DeleteBridge
     */
    private DeleteBridge $deleteBridge;
    /**
     * @var ClaseProduct
     */
    private ClaseProduct $claseProduct;

    public function __construct(CreateBridge $createBridge, UpdateBridge $updateBridge, ReadBridge $readBridge, DeleteBridge $deleteBridge, ClaseProduct $claseProduct)
    {
        $this->createBridge = $createBridge;
        $this->updateBridge = $updateBridge;
        $this->readBridge = $readBridge;
        $this->deleteBridge = $deleteBridge;
        $this->claseProduct = $claseProduct;
        $this->middleware('auth');
    }

    function getCategoria(Request $request)
    {
        return response()->json($this->readBridge->getCategoria($request));
    }
    function searchCategoria(Request $request) {
        return response()->json($this->readBridge->searchCategoria($request->params));
    }
    function store(Request $request)
    {
        return response()->json($this->createBridge->categoria($request['data']));
    }
    function editCategory($id){
        return response()->json($this->readBridge->editCategory($id));
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

}
