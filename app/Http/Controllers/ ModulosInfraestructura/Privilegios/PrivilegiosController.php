<?php


namespace App\Http\Controllers\ModulosInfraestructura\Privilegios;


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
     * @return void
     */
    public function __construct(ListPrivilegesAdapter $listPrivilegesAdapter)
    {
        $this->listPrivilegesAdapter = $listPrivilegesAdapter;
    }

    public function listPrivileges() {
        return response()->json($this->listPrivilegesAdapter->listPrivileges());
    }
}
