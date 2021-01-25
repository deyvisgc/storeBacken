<?php


namespace App\Http\Controllers\Privileges;


use Core\Privilegio\Infraestructura\AdapterBridge\ListPrivilegesAdapter;

class PrivilegesController
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
        return response()->json($this->listPrivilegesAdapter->listPrivileges());
    }
}
