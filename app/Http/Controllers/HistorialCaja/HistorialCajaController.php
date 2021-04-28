<?php


namespace App\Http\Controllers\HistorialCaja;


use App\Http\Controllers\Controller;
use Carbon\Carbon;
use Core\HistorialCaja\Domain\Entity\HistorialCajaEntity;
use Core\HistorialCaja\Infraestructura\AdapterBridge\CreateHistorialCajaAdapter;
use Core\HistorialCaja\Infraestructura\AdapterBridge\DeleteHistorialCajaAdapter;
use Core\HistorialCaja\Infraestructura\AdapterBridge\ListHistorialCajaAdapter;
use Core\HistorialCaja\Infraestructura\AdapterBridge\UpdateHistorialCajaAdapter;
use Illuminate\Http\Request;

class HistorialCajaController extends Controller
{
    private ListHistorialCajaAdapter $listHistorialCajaAdapter;
    private CreateHistorialCajaAdapter $createHistorialCajaAdapter ;
    private UpdateHistorialCajaAdapter $updateHistorialCajaAdapter;
    private DeleteHistorialCajaAdapter $deleteHistorialCajaAdapter;

    public function __construct(
        ListHistorialCajaAdapter $listHistorialCajaAdapter,
        CreateHistorialCajaAdapter $createHistorialCajaAdapter,
        UpdateHistorialCajaAdapter $updateHistorialCajaAdapter,
        DeleteHistorialCajaAdapter $deleteHistorialCajaAdapter

    )
    {
        $this->listHistorialCajaAdapter = $listHistorialCajaAdapter;
        $this->createHistorialCajaAdapter = $createHistorialCajaAdapter;
        $this->deleteHistorialCajaAdapter = $deleteHistorialCajaAdapter;
        $this->updateHistorialCajaAdapter = $updateHistorialCajaAdapter;
        $this->middleware('auth');
    }
    public function listHistorialCaja()
    {
        return response()->json($this->listHistorialCajaAdapter->listHistorial());
    }
    public function deleteHistorialCaja($idCajaHistory)
    {
        return response()->json($this->deleteHistorialCajaAdapter->deleteHistorialCaja($idCajaHistory));
    }
    public function createHistorialCaja(Request $request)
    {
        $fechaOperacion =Carbon::now('America/Lima')->toDateTimeString();
        $tipoOperacion = $request['tipoOperacion'];
        $totalDinero =$request['totalDinero'];
        $idCaja =$request['idCaja'];
        $HistorialEntity = new HistorialCajaEntity(0,$fechaOperacion,$tipoOperacion,0,$idCaja);
        return response()->json($this->createHistorialCajaAdapter->createHistorialCaja($HistorialEntity));
    }
    public function updateHistorial(Request $request){
        $id=$request->input('id');
        $fechaOperacion =Carbon::now('America/Lima')->toDateTimeString();
        $tipoOperacion = $request->input('tipoOperacion');
        $totalDinero =$request->input('totalDinero');
        $idCaja =$request->input('idCaja');
        $HistorialEntity = new  HistorialCajaEntity($id,$fechaOperacion,$tipoOperacion,$totalDinero,$idCaja);
        return response()->json($this->updateHistorialCajaAdapter->updateHistorial($HistorialEntity));
    }

}
