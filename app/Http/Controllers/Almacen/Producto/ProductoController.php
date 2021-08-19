<?php

namespace App\Http\Controllers\Almacen\Producto;

use App\Exports\Excel\Almacen\ExportProduct;
use App\Exports\Excel\Productos\ExportarProductos;
use App\Exports\Excel\Reportes\ExportarInventario;
use App\Http\Controllers\Controller;
use App\Repository\Almacen\Productos\ProductoRepositoryInterface;
use App\Repository\Compras\ComprasRepositoryInterface;
use App\Traits\Search\SeacrhTraits;
use Barryvdh\DomPDF\Facade as PDF;
use Core\Producto\Infraestructure\AdapterBridge\CreateBridge;
use Core\Producto\Infraestructure\AdapterBridge\DeleteBridge;
use Core\Producto\Infraestructure\AdapterBridge\ReadBridge;
use Core\Producto\Infraestructure\AdapterBridge\UpdateBridge;
use Core\Traits\QueryTraits;
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
    /**
     * @var ProductoRepositoryInterface
     */
    private ProductoRepositoryInterface $repository;

    public function __construct(CreateBridge $createBridge,UpdateBridge $updateBridge,ReadBridge $readBridge,DeleteBridge $deleteBridge,
                                ProductoRepositoryInterface $repository)
     {
         $this->createBridge = $createBridge;
         $this->updateBridge = $updateBridge;
         $this->readBridge = $readBridge;
         $this->deleteBridge =$deleteBridge;
         $this->repository = $repository;
         $this->middleware('auth', ['except' => [
             'Exportar'
         ]]);
     }
     use QueryTraits;
    function Read(Request $request)
    {
        return response()->json($this->repository->all($request));
    }

    function Edit(int $id)
    {
        return response()->json($this->repository->edit($id));
    }
    function Store(Request $request)
    {
        return response()->json($this->repository->create($request->params));

    }
    function getSubCategoria($id) {
        return response()->json($this->repository->show($id));
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
    function Exportar (Request $request) {
        $clase = $request->input('idClase');
        $unidad = $request->input('idUnidad');
        $desde = $request->input('desde');
        $hasta = $request->input('hasta');
        $opcion = $request->input('isExport');
        $query = $this->ObtenerProductos($clase, $unidad, $desde, $hasta);
        if ($opcion === 'excel') {
            return Excel::download(new ExportProduct($clase, $unidad, $desde, $hasta), 'reportesInventario.xlsx')->deleteFileAfterSend (false);
        } else {
            $customPaper = array(0,0,710,710);
            $pdf = PDF::loadView('Exportar.Pdf.Almacen.productos', ['productos'=>$query])->setPaper($customPaper);
            return $pdf->download('invoice.pdf');
        }

    }
    function Search(Request $request) {
        return response()->json($this->readBridge->search($request->params));
    }
    function selectProducto(Request $request) {
        return response()->json($this->readBridge->selectProducto($request));
    }
    function AjustarStock(Request $request) {
        return response()->json($this->createBridge->ajustarStock($request->params));
    }
    function selectAtributos() {
        return response()->json($this->repository->getAtributos());
    }
    function generarCodigo() {
        return response()->json($this->repository->generarCodigoBarra());
    }
}
