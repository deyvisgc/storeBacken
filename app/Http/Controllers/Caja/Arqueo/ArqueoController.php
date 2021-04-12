<?php


namespace App\Http\Controllers\Caja\Arqueo;


use App\Http\Controllers\Controller;
use App\Http\Excepciones\Exepciones;
use Core\ArqueoCaja\Infraestructure\Adapter\ArqueoCreateAdapter;
use Core\ArqueoCaja\Infraestructure\Adapter\ArqueoReadAdapter;
use Illuminate\Database\QueryException;
use Illuminate\Http\Request;

class ArqueoController extends Controller
{
    /**
     * @var ArqueoReadAdapter
     */
    private ArqueoReadAdapter $readAdapter;
    /**
     * @var ArqueoCreateAdapter
     */
    private ArqueoCreateAdapter $createAdapter;

    public function __construct(ArqueoReadAdapter $readAdapter, ArqueoCreateAdapter $createAdapter)
    {
        $this->readAdapter = $readAdapter;
        $this->createAdapter = $createAdapter;
    }
    function ObtenerTotales(Request $request) {
        return response()->json($this->readAdapter->ObtenerTotales($request));
    }
    function GuardarArqueo(Request  $request) {
        return response()->json($this->createAdapter->Create($request->params));
    }
}
