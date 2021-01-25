<?php

namespace App\Http\Controllers\Rol;

use App\Http\Controllers\Controller;
use Core\Rol\Infraestructura\AdapterBridge\ListRolAdapter;

class RolController extends Controller
{
    /**
     * @var ListRolAdapter
     */
    private ListRolAdapter $listRolAdapter;

    /**
     * Create a new controller instance.
     *
     * @return void
     */
    public function __construct(
        ListRolAdapter $listRolAdapter
    )
    {
        $this->listRolAdapter = $listRolAdapter;
    }

    public function listRol() {
        return response()->json($this->listRolAdapter->listRol());
    }

}
