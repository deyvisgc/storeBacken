<?php

namespace App\Http\Controllers\Compras;
use App\Http\Controllers\Controller;
use Core\Compras\Infraestructure\Adapter_Bridge\ReadBridge;
use Core\Traits\CarritoTraits;

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\File;
use Illuminate\Http\Request;

class ComprasController extends Controller
{
    use CarritoTraits;

    /**
     * @var ReadBridge
     */
    private ReadBridge $redBridge;

    public function __construct(ReadBridge $readBridge)
    {
        $this->redBridge = $readBridge;
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
        return  response()->json($this->redBridge->__invoke($request));
    }
    public function Detalle(int $id) {
        return  response()->json($this->redBridge->__Detalle($id));
    }
    public function VerPdf(Request $request) {
        return   $image_file_path = storage_path("Comprobantes/3f104f95-c3ee-4126-8a4c-1757acfcf354_1616589571.pdf");
        $imagen = DB::table('compra')->where('idCompra', $id)->get();
        $path = storage_path('app\public\Comprobantes') . '/' . $imagen[0]->comUrlComprobante;
        $file = File::get($path);
        $type = File::mimeType($path);
        $response = response()->make($file, 200);
        $response->header("Content-Type", $type);
        return $response;
        return response()->json();

    }
}
