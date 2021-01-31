<?php

namespace App\Http\Controllers\Almacen\Producto;

use App\Http\Controllers\Controller;
use Core\Producto\Infraestructure\AdapterBridge\CreateBridge;
use Core\Producto\Infraestructure\AdapterBridge\DeleteBridge;
use Core\Producto\Infraestructure\AdapterBridge\ReadBridge;
use Core\Producto\Infraestructure\AdapterBridge\UpdateBridge;
use Illuminate\Http\Request;

class ProductoController extends Controller
{
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

    public function __construct(CreateBridge $createBridge,UpdateBridge $updateBridge,ReadBridge $readBridge,DeleteBridge $deleteBridge)
     {
         $this->createBridge = $createBridge;
         $this->updateBridge = $updateBridge;
         $this->readBridge = $readBridge;
         $this->deleteBridge =$deleteBridge;
     }

    function Store(Request $request)
    {
        try {
            return response()->json($this->createBridge->__invoke($request));
        }catch (\Exception $exception) {
            return $exception->getMessage();
        }
    }

    function Update(Request $request)
    {
        return response()->json($this->updateBridge->__invoke($request));
    }

    function Read()
    {
        return response()->json($this->readBridge->__invoke());
    }

    function Readxid(int $id)
    {
        return response()->json($this->readBridge->__invokexid($id));
    }

    function delete(int $id)
    {
     return response()->json($this->deleteBridge->__invokexid($id));
    }
    function CambiarStatus(int $id)
    {
        return response()->json($this->deleteBridge->__invokexid($id));
    }

}
