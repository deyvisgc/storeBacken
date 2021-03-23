<?php

namespace App\Http\Controllers\Compras;
use App\Http\Controllers\Controller;
use Core\Compras\Infraestructure\Adapter_Bridge\ReadBridge;
use Core\Traits\CarritoTraits;
use Illuminate\Http\Request;

class ComprasController extends Controller
{
    use CarritoTraits;

    /**
     * @var ReadBridge
     */
    private ReadBridge $createBridge;

    public function __construct(ReadBridge $readBridge)
    {
        $this->createBridge = $readBridge;
    }
    public function Proveedor() {
        return response()->json($this->searchProveedor());
    }
    public function Addcar (Request $request) {
        return response()->json($this->Addcarrito($request->data));
    }
    public function ListarCarr(int $idpersona){
     return response()->json($this->Listar($idpersona));
    }
    public function UpdateCantidad(Request $request) {
        return response()->json($this->ActualizarCantidad($request->data));
    }
    public function Delete(Request $request) {
        return response()->json($this->DeleteCarr($request->data));
    }
    public function Pagar(Request $request) {
        return response()->json($this->PagarCompra($request));
    }
    public function Compras(Request $request) {
        return  response()->json($this->createBridge->__invoke($request));
    }
    public function Detalle(int $id) {
        return  response()->json($this->createBridge->__Detalle($id));
    }

}
