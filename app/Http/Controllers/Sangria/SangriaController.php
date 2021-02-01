<?php


namespace App\Http\Controllers\Sangria;


use App\Http\Controllers\Controller;
use Core\Sangria\Domain\Entity\SangriaEntity;
use Core\Sangria\Infraestructura\AdapterBridge\CreateSangriaAdapter;
use Core\Sangria\Infraestructura\AdapterBridge\DeleteSangriaAdapter;
use Core\Sangria\Infraestructura\AdapterBridge\EditSangriaAdapter;
use Core\Sangria\Infraestructura\AdapterBridge\ListSangriaAdapter;
use Illuminate\Http\Request;
use Carbon\Carbon;


class SangriaController extends Controller
{
    private ListSangriaAdapter $listSangriaAdapter;
    private CreateSangriaAdapter $createSangriaAdapter;
    private EditSangriaAdapter $editSangriaAdapter;
    private DeleteSangriaAdapter $deleteSangriaAdapter;

    public function __construct(
        ListSangriaAdapter $listSangriaAdapter,
        CreateSangriaAdapter $createSangriaAdapter,
        EditSangriaAdapter $editSangriaAdapter,
        DeleteSangriaAdapter $deleteSangriaAdapter
    )
    {
        $this->listSangriaAdapter = $listSangriaAdapter;
        $this->createSangriaAdapter = $createSangriaAdapter;
        $this->editSangriaAdapter = $editSangriaAdapter;
        $this->deleteSangriaAdapter=$deleteSangriaAdapter;
    }
    public function listSangria()
    {
        return response()->json($this->listSangriaAdapter->listSangria());
    }
    public function deleteSangria($idSangria)
    {
        return response()->json($this->deleteSangriaAdapter->deleteSangria($idSangria));
    }
    public function createSangria(Request $request)
    {
        $sanMonto = $request['sanMonto'];
        $sanFecha= Carbon::now('America/Lima')->toDateTimeString();
        $sanTipo= $request['sanTipo'];
        $sanMotivo= $request['sanMotivo'];
        $idCaja= $request['idCaja'];
        $idUser= $request['idUser'];
        $sangriaEntity = new SangriaEntity(0,$sanMonto,$sanFecha,$sanTipo,$sanMotivo,$idCaja,$idUser);
        return response()->json($this->createSangriaAdapter->createSangria($sangriaEntity));
    }
    public function updateSangria(Request $request){

        $id=$request->input('id');
        $sanMonto = $request->input('sanMonto');
        $sanFecha= Carbon::now('America/Lima')->toDateTimeString();
        $sanTipo= $request->input('sanTipo');
        $sanMotivo= $request->input('sanMotivo');
        $idCaja= $request->input('idCaja');
        $idUser= $request->input('idUser');
        $sangriaEntity = new SangriaEntity($id,$sanMonto,$sanFecha,$sanTipo,$sanMotivo,$idCaja,$idUser);
        return response()->json($this->editSangriaAdapter->editSangria($sangriaEntity));
    }
}
