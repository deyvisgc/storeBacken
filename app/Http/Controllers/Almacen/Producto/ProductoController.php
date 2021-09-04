<?php

namespace App\Http\Controllers\Almacen\Producto;

use App\Exports\Excel\Almacen\ExportProduct;
use App\Http\Controllers\Controller;
use App\Repository\Almacen\Productos\ProductoRepositoryInterface;
use App\Traits\Search\SeacrhTraits;
use Barryvdh\DomPDF\Facade as PDF;
use Carbon\Carbon;
use Core\Traits\QueryTraits;
use Illuminate\Http\Request;
use Maatwebsite\Excel\Facades\Excel;


class ProductoController extends Controller
{
    use SeacrhTraits;
    /**
     * @var ProductoRepositoryInterface
     */
    private ProductoRepositoryInterface $repository;

    public function __construct(ProductoRepositoryInterface $repository)
     {
         $this->repository = $repository;
         $this->middleware('auth', ['except' => [
             'Exportar'
         ]]);
     }
     use QueryTraits;
    function read(Request $request)
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
        return response()->json($this->repository->delete($id));
    }
    function selectProducto(Request $request) {
        return response()->json($this->repository->selectProducto($request));
    }
    function ajustarStock(Request $request) {
        return response()->json($this->repository->ajustarStock($request));
    }
    function changeStatus (Request $request) {
        return response()->json($this->repository->changeStatus($request->params));
    }
    function Exportar (Request $request) {
        $clase = $request->input('idClase');
        $unidad = $request->input('idUnidad');
        $fechaDesde= Carbon::make($request->desde)->format('Y-m-d');
        $fechaHasta= Carbon::make($request->hasta)->format('Y-m-d');
        $opcion = $request->input('isExport');
        $lita = $this->ObtenerProductos($clase, $unidad, $fechaDesde, $fechaHasta, $request->fechaVencimiento);
        if ($opcion === 'excel') {
            return Excel::download(new ExportProduct($lita), 'reportesInventario.xlsx')->deleteFileAfterSend (false);
        } else {
            $customPaper = array(0,0,710,710);
            $pdf = PDF::loadView('Exportar.Pdf.Almacen.productos', ['productos'=>$lita])->setPaper($customPaper);
            return $pdf->download('invoice.pdf');
        }
    }
    function selectAtributos() {
        return response()->json($this->repository->getAtributos());
    }
    function generarCodigo() {
        return response()->json($this->repository->generarCodigoBarra());
    }
   /* function SearchxType (Request $request) {
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
    function LastIdProducto () {
        return response()->json($this->readBridge->__invokeLastId());
    }
    function Search(Request $request) {
        return response()->json($this->readBridge->search($request->params));
    }
   */
}
