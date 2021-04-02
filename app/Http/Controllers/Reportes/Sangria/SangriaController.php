<?php


namespace App\Http\Controllers\Reportes\Sangria;


use App\Http\Controllers\Controller;
use Core\Reportes\Infraestructure\Adapter\SangriaAdapter;
use Illuminate\Http\Request;
use const Core\Reportes\Infraestructure\Sql\result;

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
}
