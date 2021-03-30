<?php


namespace App\Http\Controllers\Privileges;


use App\Http\Controllers\Controller;
use Core\Privilegio\Infraestructura\AdapterBridge\ListPrivilegesAdapter;
use Core\Privilegio\Infraestructura\AdapterBridge\ListPrivilegesByRolAdapter;
use Illuminate\Http\Request;

class PrivilegesController extends Controller
{
    /**
     * @var ListPrivilegesAdapter
     */
    private ListPrivilegesAdapter $listPrivilegesAdapter;
    /**
     * @var ListPrivilegesByRolAdapter
     */
    private ListPrivilegesByRolAdapter $listPrivilegesByRolAdapter;

    /**
     * Create a new controller instance.
     *
     * @param ListPrivilegesAdapter $listPrivilegesAdapter
     */
    public function __construct(
        ListPrivilegesAdapter $listPrivilegesAdapter,
        ListPrivilegesByRolAdapter $listPrivilegesByRolAdapter
    )
    {
        $this->listPrivilegesAdapter = $listPrivilegesAdapter;
        $this->listPrivilegesByRolAdapter = $listPrivilegesByRolAdapter;
    }

    public function listPrivileges() {
        return response()->json($this->listPrivilegesAdapter->listPrivileges());
    }

    public function listPrivilegesByRol(Request $request) {
        $idRol = $request['idRol'];
        return response()->json($this->listPrivilegesByRolAdapter->listPrivilegesByRol($idRol));
    }

}
