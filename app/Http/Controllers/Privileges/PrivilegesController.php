<?php


namespace App\Http\Controllers\Privileges;


use App\Http\Controllers\Controller;
use Core\Privilegio\Infraestructura\AdapterBridge\CreatePrivilegioAdapter;
use Core\Privilegio\Infraestructura\AdapterBridge\DeletePrivilegios;
use Core\Privilegio\Infraestructura\AdapterBridge\ListPrivilegesByRolAdapter;
use Core\Privilegio\Infraestructura\AdapterBridge\UpdatePrivilegioAdapter;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class PrivilegesController extends Controller
{

    private ListPrivilegesByRolAdapter $listPrivilegesByRolAdapter;
    /**
     * @var CreatePrivilegioAdapter
     */
    private CreatePrivilegioAdapter $createPrivilegioAdapter;
    /**
     * @var DeletePrivilegios
     */
    private DeletePrivilegios $deletePrivilegios;
    /**
     * @var UpdatePrivilegioAdapter
     */
    private UpdatePrivilegioAdapter $updatePrivilegioAdapter;

    public function __construct(ListPrivilegesByRolAdapter $listPrivilegesByRolAdapter,
                                CreatePrivilegioAdapter $createPrivilegioAdapter,
                                DeletePrivilegios $deletePrivilegios,
                                UpdatePrivilegioAdapter $updatePrivilegioAdapter)
    {
        $this->listPrivilegesByRolAdapter = $listPrivilegesByRolAdapter;
        $this->middleware('auth');
        $this->createPrivilegioAdapter = $createPrivilegioAdapter;
        $this->deletePrivilegios = $deletePrivilegios;
        $this->updatePrivilegioAdapter = $updatePrivilegioAdapter;
    }

     function listPrivilegesByRol(Request $request) {
        $privi = $request['idRol'];
        return response()->json($this->listPrivilegesByRolAdapter->listPrivilegesByRol($privi));
    }
     function listIcon() {
        $icon = DB::table('icon')->select('*')->get();
        return $icon;
    }
    // Grupo
    function AddGrupos(Request $request) {
        return response()->json($this->createPrivilegioAdapter->guardarPrivilegio($request->grupos));
    }
    function GetGrupo() {
        return response()->json($this->listPrivilegesByRolAdapter->getGrupos());
    }
    function GetGrupoDetalle(int $id) {
        return response()->json($this->listPrivilegesByRolAdapter->getGruposDetalle($id));
    }
    function DeletePrivilegioGrupo(Request  $request) {
        return response()->json($this->deletePrivilegios->EliminarPrivilegioGrupo($request->data));
    }
    // Privilegios
    function GetPrivilegios() {
        return response()->json($this->listPrivilegesByRolAdapter->getPrivilegios());
    }
    function UpdatePrivilegios(Request $request) {
        return response()->json($this->updatePrivilegioAdapter->updatePrivilegio($request->data));
    }
    function ChangeStatus(Request $request) {
        return response()->json($this->updatePrivilegioAdapter->changeStatusGrupo($request->data));

    }

}
