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

    public function Read()
    {
        return response()->json($this->readBridge->__invoke());
    }

    public function store(Request $request)
    {
        return response()->json($this->createBridge->__invoke($request));
    }

    public function getclasesuperior()
    {
        return response()->json($this->readBridge->__clasesuperior());
    }

    public function recursiveChildren()
    {
        return response()->json($this->readBridge->__getclaserecursiva());
    }

    public function Obtenerclasexid(int $idpadre) {
        return response()->json($this->readBridge->__Obtenerclasexid($idpadre));
    }
    public function update(Request $request) {
        return response()->json($this->updateBridge->__invoke($request->data));
    }
    public function viewchild(int $id) {
        return response()->json($this->readBridge->__viewchild($id));
    }
    public function Actualizarcate(Request $request) {
        return response()->json($this->updateBridge->__Actualizarcate($request->data));
    }
    public function Changestatuscate(Request $request) {
        return response()->json($this->updateBridge->__Changestatu($request->data));
    }
    public function ChangestatusCateRecursiva(Request $request) {
        return response()->json($this->updateBridge->__ChangestatuRecursiva($request->data));
    }
    public function filtrarxclasepadre(int $idpadre) {
        return response()->json($this->Padreehijoclasexid($idpadre));
    }

}
