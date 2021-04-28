<?php

namespace App\Http\Controllers\Rol;

use App\Http\Controllers\Controller;
use Core\Rol\Domain\Entity\RolEntity;
use Core\Rol\Infraestructura\AdapterBridge\ChangeStatusRolAdapter;
use Core\Rol\Infraestructura\AdapterBridge\CreateRolAdapter;
use Core\Rol\Infraestructura\AdapterBridge\DeleteRolAdapter;
use Core\Rol\Infraestructura\AdapterBridge\EditRolAdapter;
use Core\Rol\Infraestructura\AdapterBridge\ListRolAdapter;
use Core\Rol\Infraestructura\AdapterBridge\ListRolByIdAdapter;
use Illuminate\Http\Request;

class RolController extends Controller
{
    /**
     * @var ListRolAdapter
     */
    private ListRolAdapter $listRolAdapter;
    /**
     * @var CreateRolAdapter
     */
    private CreateRolAdapter $createRolAdapter;
    /**
     * @var EditRolAdapter
     */
    private EditRolAdapter $editRolAdapter;
    /**
     * @var DeleteRolAdapter
     */
    private DeleteRolAdapter $deleteRolAdapter;
    /**
     * @var ListRolByIdAdapter
     */
    private ListRolByIdAdapter $listRolByIdAdapter;
    /**
     * @var ChangeStatusRolAdapter
     */
    private ChangeStatusRolAdapter $changeStatusRolAdapter;

    /**
     * Create a new controller instance.
     *
     * @return void
     */
    public function __construct(
        CreateRolAdapter $createRolAdapter,
        ListRolAdapter $listRolAdapter,
        EditRolAdapter $editRolAdapter,
        DeleteRolAdapter $deleteRolAdapter,
        ChangeStatusRolAdapter $changeStatusRolAdapter
    )
    {
        $this->listRolAdapter = $listRolAdapter;
        $this->createRolAdapter = $createRolAdapter;
        $this->editRolAdapter = $editRolAdapter;
        $this->deleteRolAdapter = $deleteRolAdapter;
        $this->changeStatusRolAdapter = $changeStatusRolAdapter;
        $this->middleware('auth');
    }

    public function listRol() {
        return response()->json($this->listRolAdapter->listRol());
    }

    public function createRol(Request $request) {
        // Obteniendo los datos enviados desde el cliente
        $name = $request->rol['rolName'];
        // Intanciando una entidad para pasarlo como parametro al metodo createRol
        $rolEntity = new RolEntity($name,'ACTIVE', 0);

        // ejecutando y respondiendo desde el metodo createRol
        return response()->json($this->createRolAdapter->createRol($rolEntity));
    }

    public function updateRol(Request $request){
        $id = $request['rol']['idRol'];
        $name = $request['rol']['rolName'];
        $rolEntity = new RolEntity($name,$id);

        return response()->json($this->editRolAdapter->editRol($rolEntity));
    }

    public function deleteRol($idRol) {
        return response()->json($this->deleteRolAdapter->deleteRol($idRol));
    }
    public function changeStatus(Request $request) {
        $idRol = $request->data['id_rol'];
        $status = $request->data['rol_status'];
        return response()->json($this->changeStatusRolAdapter->changeStatusRol($idRol, $status));
    }
}
