<?php


namespace App\Http\Controllers\Reportes\Sangria;


use App\Exports\Excel\Reportes\ExportarInventario;
use App\Exports\Excel\Reportes\ExportarSangria;
use App\Http\Controllers\Controller;
use Core\Reportes\Infraestructure\Adapter\SangriaAdapter;
use Illuminate\Http\Request;
use Maatwebsite\Excel\Facades\Excel;
use const Core\Reportes\Infraestructure\Database\result;

class SangriaController extends Controller
{
    /**
     * @var SangriaAdapter
     */
    private SangriaAdapter $sangriaAdapter;

    public function __construct(SangriaAdapter $sangriaAdapter)
     {
         $this->sangriaAdapter = $sangriaAdapter;
     }

    function GetSangria(Request $request) {
        return response()->json($this->sangriaAdapter->getSangria($request));
    }
    function AddSangria (Request $request) {
        return response()->json($this->sangriaAdapter->AddSangria($request));
    }
    function DeleteSangria(Request $request) {
        return response()->json($this->sangriaAdapter->deleteSangria($request));
    }
    function excel(Request $request)
    {
        $fechaDesde = $request->input('fechaDesde');
        $fechaHasta = $request->input('fechaHasta');
        $caja = $request->input('caja');
        $tipoSangria = $request->input('tipoSangria');
        return Excel::download(new ExportarSangria($fechaDesde, $fechaHasta, $caja, $tipoSangria), 'reportesSangria.xlsx')->deleteFileAfterSend (false);
    }
}
