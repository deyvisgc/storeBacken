<?php

namespace App\Http\Controllers\Compras;
use App\Exports\Excel\ComprasCredito;
use App\Exports\Excel\ComprasCreditoBuyID;
use App\Exports\HistorialPagosExport;
use App\Http\Controllers\Controller;
use Core\Compras\Infraestructure\Adapter_Bridge\ReadBridge;
use Core\Traits\CarritoTraits;

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\File;
use Illuminate\Http\Request;
use Maatwebsite\Excel\Facades\Excel;

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
    public function Exportar(Request $request) {
        $tabla = $request['tabla'];
        $fechaDesde = $request['fechaDesde'];
        $fechaHasta = $request['fechaHasta'];
        $codeProveedor = $request['codeProveedor'];
        $tipoPago      = $request['tipoPago'];
        $tipoComprobante =$request['tipoComprobante'];
        return Excel::download(new ComprasCredito($tabla,$fechaDesde,$fechaHasta,$codeProveedor,$tipoPago,$tipoComprobante), 'reportescompras.xlsx')->deleteFileAfterSend (false);
    }
    public function ExportarById(int $id) {

        return Excel::download(new ComprasCreditoBuyID($id), 'reportescompras.xlsx')->deleteFileAfterSend (false);
    }

}
