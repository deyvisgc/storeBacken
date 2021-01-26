<?php

namespace App\Http\Controllers\Rol;

use App\Http\Controllers\Controller;
use Core\Rol\Domain\Entity\RolEntity;
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
     * Create a new controller instance.
     *
     * @return void
     */
    public function __construct(
        CreateRolAdapter $createRolAdapter,
        ListRolAdapter $listRolAdapter,
        EditRolAdapter $editRolAdapter,
        DeleteRolAdapter $deleteRolAdapter,
        ListRolByIdAdapter $listRolByIdAdapter
    )
    {
        $this->listRolAdapter = $listRolAdapter;
        $this->createRolAdapter = $createRolAdapter;
        $this->editRolAdapter = $editRolAdapter;
        $this->deleteRolAdapter = $deleteRolAdapter;
        $this->listRolByIdAdapter = $listRolByIdAdapter;
    }

    public function listRol() {
        return response()->json($this->listRolAdapter->listRol());
    }

    public function createRol(Request $request) {
        // Obteniendo los datos enviados desde el cliente
        $name = $request['rolName'];
        // Intanciando una entidad para pasarlo como parametro al metodo createRol
        $rolEntity = new RolEntity($name,'ACTIVE', 0);

        // ejecutando y respondiendo desde el metodo createRol
        return response()->json($this->createRolAdapter->createRol($rolEntity));
    }

    public function updateRol(Request $request){
        $id = $request->input('idRol');
        $name = $request->input('rolName');
        $status = $request->input('rolStatus');

        $rolEntity = new RolEntity($name,$status,$id);

        return response()->json($this->editRolAdapter->editRol($rolEntity));
    }

    public function deleteRol($idRol) {
        return response()->json($this->deleteRolAdapter->deleteRol($idRol));
    }

    public function listRolById($idRol) {
        return response()->json($this->listRolByIdAdapter->listRolById($idRol));
    }
}
