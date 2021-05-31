<?php


namespace App\Http\Controllers\Reportes;


use App\Exports\Excel\ComprasCreditoBuyID;
use App\Exports\Excel\Reportes\exportarInventario;
use App\Http\Controllers\Controller;
use Core\Reportes\Infraestructure\Adapter\InventarioAdapter;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Barryvdh\DomPDF\Facade as PDF;
use Maatwebsite\Excel\Facades\Excel;

class InventarioController extends Controller
{
    /**
     * @var InventarioAdapter
     */
    private InventarioAdapter $inventarioAdapter;

    public function __construct(InventarioAdapter $inventarioAdapter)
    {
        $this->inventarioAdapter = $inventarioAdapter;
        //$this->middleware('auth');
    }

    public function Inventario(Request $request)
    {
        return response()->json($this->inventarioAdapter->__Inventario($request));
    }
    public function Pdf() {

        $data =  DB::select("select * from product");
        $customPaper = array(0,0,660,660);
        $pdf = PDF::loadView('Exportar.Pdf.invoice', ['data'=>$data])->setPaper($customPaper);
        return $pdf->download('invoice.pdf');
    }
    public function ExportarInventario(Request $request) {
        $codigo = $request->input('codigo');
        $nombre = $request->input('nombre');
        $categoria = $request->input('categoria');
        return Excel::download(new exportarInventario($codigo, $nombre, $categoria), 'reportesInventario.xlsx')->deleteFileAfterSend (false);
    }
    public function probar () {
        $data = [];
        $query = DB::table('product as p');
        $query->join('clase_producto as cl', 'p.id_clase_producto', '=', 'cl.id_clase_producto')
            ->select('p.pro_code', 'p.pro_name','cl.clas_name','p.pro_cantidad','p.pro_precio_venta',
                DB::raw('p.pro_cantidad * p.pro_precio_venta as total'))
            ->orderBy('pro_cantidad','desc');
        $result= $query->get();
        $suma = 0;
        foreach ($result as $value) {
            $suma += $value->total;
        }
        return (float)$suma;
    }
}
