<?php


namespace App\Http\Controllers\Privilegios;


use Core\Privilegio\Infraestructura\AdapterBridge\ListPrivilegesAdapter;

class PrivilegiosController
{
    /**
     * @var ListPrivilegesAdapter
     */
    private ListPrivilegesAdapter $listPrivilegesAdapter;

    /**
     * Create a new controller instance.
     *
     * @param ListPrivilegesAdapter $listPrivilegesAdapter
     */
    public function __construct(ListPrivilegesAdapter $listPrivilegesAdapter)
    {
        $this->listPrivilegesAdapter = $listPrivilegesAdapter;
    }

    public function listPrivileges() {
        return 'json rsponse';
        return response()->json($this->listPrivilegesAdapter->listPrivileges());
    }
}
