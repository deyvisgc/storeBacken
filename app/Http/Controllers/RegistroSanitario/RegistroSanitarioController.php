<?php


namespace App\Http\Controllers\RegistroSanitario;

use App\Http\Controllers\Controller;
use Core\RegistroSanitario\Domain\Entity\RegistroSanitarioEntity;
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
    private CreateRegistroSanitarioAdapter $createRegistroSanitarioAdapter;
    private DeleteRegistroSanitarioAdapter $deleteRegistroSanitarioAdapter;
    private UpdateRegistroSanitarioAdapter $updateRegistroSanitarioAdapter;




    public function __construct(
        ListarRegistroSanitarioAdapter $listarRegistroSanitarioAdapter,
        CreateRegistroSanitarioAdapter $createRegistroSanitarioAdapter,
        DeleteRegistroSanitarioAdapter $deleteRegistroSanitarioAdapter,
        UpdateRegistroSanitarioAdapter $updateRegistroSanitarioAdapter
    )
    {

        $this->listarRegistroSanitarioAdapter = $listarRegistroSanitarioAdapter;
        $this->createRegistroSanitarioAdapter = $createRegistroSanitarioAdapter;
        $this->deleteRegistroSanitarioAdapter = $deleteRegistroSanitarioAdapter;
        $this->updateRegistroSanitarioAdapter = $updateRegistroSanitarioAdapter;
    }
    public function listarRegistroSanitario()
    {
        return response()->json($this->listarRegistroSanitarioAdapter->listRegistroSanitario());
    }
    public function createRegistro(Request $request){
        $codigo = $request ['rsCodigo'];
        $fecha = $request['rsFecha'];
        $descripcion = $request['rsDescripcion'];
        $registroEntity = new RegistroSanitarioEntity(0, $codigo, $fecha,$descripcion );

        return response()->json($this->createRegistroSanitarioAdapter->createRegistro($registroEntity));
    }
    public function updateRegistro (Request $request)
    {
        $id = $request->input('idRegistro');
        $codigo = $request->input('rsCodigo');
        $fecha = $request->input('rsFecha');
        $descripcion = $request->input('rsDescripcion');

        $registroEntity = new RegistroSanitarioEntity($id, $codigo, $fecha, $descripcion);

        return response()->json($this->updateRegistroSanitarioAdapter->updateRegistro($registroEntity));
    }
    public function deleteRegistro($idRegistroSanitario)
    {
        return response()->json($this->deleteRegistroSanitarioAdapter->deleteRegistro($idRegistroSanitario));
    }
}
