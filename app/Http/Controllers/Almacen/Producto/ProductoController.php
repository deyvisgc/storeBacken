<?php

namespace App\Http\Controllers\Almacen\Producto;

use App\Exports\Excel\Almacen\ExportProduct;
use App\Exports\Excel\Productos\ExportarProductos;
use App\Exports\Excel\Reportes\ExportarInventario;
use App\Http\Controllers\Controller;
use App\Traits\Search\SeacrhTraits;
use Core\Producto\Infraestructure\AdapterBridge\CreateBridge;
use Core\Producto\Infraestructure\AdapterBridge\DeleteBridge;
use Core\Producto\Infraestructure\AdapterBridge\ReadBridge;
use Core\Producto\Infraestructure\AdapterBridge\UpdateBridge;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Maatwebsite\Excel\Facades\Excel;


class ProductoController extends Controller
{
    use SeacrhTraits;
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
         $this->middleware('auth', ['except' => [
             'Exportar'
         ]]);
     }
    function Read(Request $request)
    {
        return response()->json($this->readBridge->__invoke($request));
    }

    function Edit(Request $request)
    {
        return response()->json($this->readBridge->Edit($request));
    }
    function Store(Request $request)
    {
        return response()->json($this->createBridge->__invoke($request));
    }
    function delete(int $id)
    {
     return response()->json($this->deleteBridge->__invokexid($id));
    }
    function SearchxType (Request $request) {
        $status= '';
        switch ($request['data'][0]['typesearch']){
            case 'lote':
                $status = $this->seachxlote($request['data'][0]['id']);
                break;
            case 'clase' :
                $status = $this->seachxclase($request['data'][0]['id']);
                break;
            case 'unidad' :
                $status = $this->seachxunidad($request['data'][0]['id']);
                break;
        }
        return response()->json($status);
    }
    function changeStatus (Request $request) {
        return response()->json($this->updateBridge->changestatus($request));
    }
    function LastIdProducto () {
        return response()->json($this->readBridge->__invokeLastId());
    }
   public function Exportar (Request $request) {
        $clase = $request->input('idClase');
        $unidad = $request->input('idUnidad');
        $desde = $request->input('desde');
        $hasta = $request->input('hasta');
        $opcion = $request->input('isExport');
        if ($opcion === 'excel') {
            return Excel::download(new ExportProduct($clase, $unidad, $desde, $hasta), 'reportesInventario.xlsx')->deleteFileAfterSend (false);
        } else {
            return 'PDF';
        }

    }
}
