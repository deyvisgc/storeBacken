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
     * @var ListarRegistroSanitarioAdapter
     */
    private ListarRegistroSanitarioAdapter $listarRegistroSanitarioAdapter;

    public function __construct(ListarRegistroSanitarioAdapter $listarRegistroSanitarioAdapter)
    {

        $this->listarRegistroSanitarioAdapter = $listarRegistroSanitarioAdapter;
    }
    public function listarRegistroSanitario()
    {
        return response()->json($this->listarRegistroSanitarioAdapter->listRegistroSanitario());
    }
}
