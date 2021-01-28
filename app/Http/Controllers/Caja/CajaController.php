<?php


namespace App\Http\Controllers\Caja;


use App\Http\Controllers\Controller;
use Core\Caja\Domain\Entity\CajaEntity;
use Core\Caja\Infraestructura\AdapterBridge\CreateCajaAdapter;
use Core\Caja\Infraestructura\AdapterBridge\DeleteCajaAdapter;
use Core\Caja\Infraestructura\AdapterBridge\ListCajaAdapter;
use Core\Caja\Infraestructura\AdapterBridge\UpdateCajaAdapter;
use Illuminate\Http\Request;

class CajaController extends Controller
{
    private ListCajaAdapter $listCajaAdapter;
    private CreateCajaAdapter $createCajaAdapter;
    private UpdateCajaAdapter $updateCajaAdapter;
    private DeleteCajaAdapter $deleteCajaAdapter;

    public function __construct(
        ListCajaAdapter $listCajaAdapter,
        CreateCajaAdapter $createCajaAdapter,
        UpdateCajaAdapter $updateCajaAdapter,
        DeleteCajaAdapter $deleteCajaAdapter
    )
    {
        $this->listCajaAdapter = $listCajaAdapter;
        $this->createCajaAdapter =$createCajaAdapter;
        $this->updateCajaAdapter =$updateCajaAdapter;
        $this->deleteCajaAdapter = $deleteCajaAdapter;
    }
    public function listCaja()
    {
        return response()->json($this->listCajaAdapter->listCaja());
    }
    public function createCaja(Request $request)
    {
        /**$idCaja*/
        $cajaName=$request['ca_name'];
        $cajaDescription=$request['ca_description'];
        $cajaStatus=$request['ca_status'];
        $idUser=$request['id_user'];
        $cajaEntity = new CajaEntity(0,$cajaName,$cajaDescription,$cajaStatus,$idUser);

        return response()->json($this->createCajaAdapter->createCaja($cajaEntity));
    }
    public function updateCaja(Request $request)
    {
        $idCaja=$request->input('id_caja');
        $cajaName=$request->input('ca_name');
        $cajaDescription=$request->input('ca_description');
        $cajaStatus=$request->input('ca_status');
        $idUser=$request->input('id_user');

        $cajaEntity =new CajaEntity($idCaja,$cajaName,$cajaDescription,$cajaStatus,$idUser);
        return response()->json($this->updateCajaAdapter->updateCaja($cajaEntity));
    }
    public function deleteCaja($idCaja)
    {
        return response()->json($this->deleteCajaAdapter->deleteCaja($idCaja));
    }
}
