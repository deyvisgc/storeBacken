<?php


namespace App\Http\Controllers\RegistroSanitario;

use App\Http\Controllers\Controller;
use Core\RegistroSanitario\Infraestructura\AdaptersBridge\CreateRegistroSanitarioAdapter;
use Core\RegistroSanitario\Infraestructura\AdaptersBridge\DeleteRegistroSanitarioAdapter;
use Core\RegistroSanitario\Infraestructura\AdaptersBridge\ListarRegistroSanitarioAdapter;
use Core\RegistroSanitario\Infraestructura\AdaptersBridge\UpdateRegistroSanitarioAdapter;
use Illuminate\Http\Request;

class RegistroSanitarioController extends Controller
{
    /**
     * @var CreateRegistroSanitarioAdapter
     */
    private CreateRegistroSanitarioAdapter $createRegistroSanitarioAdapter;
    /**
     * @var DeleteRegistroSanitarioAdapter
     */
    private DeleteRegistroSanitarioAdapter $deleteRegistroSanitarioAdapter;
    /**
     * @var ListarRegistroSanitarioAdapter
     */
    private ListarRegistroSanitarioAdapter $listarRegistroSanitarioAdapter;
    /**
     * @var UpdateRegistroSanitarioAdapter
     */
    private UpdateRegistroSanitarioAdapter $updateRegistroSanitarioAdapter;

    public function __construct(
        CreateRegistroSanitarioAdapter $createRegistroSanitarioAdapter,
        DeleteRegistroSanitarioAdapter $deleteRegistroSanitarioAdapter,
        ListarRegistroSanitarioAdapter $listarRegistroSanitarioAdapter,
        UpdateRegistroSanitarioAdapter $updateRegistroSanitarioAdapter,
    )
    {
        $this->createRegistroSanitarioAdapter = $createRegistroSanitarioAdapter;
        $this->deleteRegistroSanitarioAdapter = $deleteRegistroSanitarioAdapter;
        $this->listarRegistroSanitarioAdapter = $listarRegistroSanitarioAdapter;
        $this->updateRegistroSanitarioAdapter = $updateRegistroSanitarioAdapter;
    }

    public function crearRegistroSanitario(Request $data){

    }

    public function listarRegistroSanitario(){

    }

    public function updateRegistroSanitario() {

    }

    public function deleteRegistroSanitario() {

    }
}
