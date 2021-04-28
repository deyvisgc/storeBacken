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
        $this->middleware('auth');
    }
    public function listarRegistroSanitario()
    {
        return response()->json($this->listarRegistroSanitarioAdapter->listRegistroSanitario());
    }
    public function createRegistro(Request $request){
        $codigo = $request ['rs_codigo'];
        $fechaVencimiento = $request['rs_fecha_vencimiento'];
        $descripcion = $request['rs_descripcion'];
        $registroEntity = new RegistroSanitarioEntity(0, $codigo, $fechaVencimiento,$descripcion  );

        return response()->json($this->createRegistroSanitarioAdapter->createRegistro($registroEntity));
    }
    public function updateRegistro (Request $request)
    {
        $id = $request->input('id_registro_sanitario');
        $codigo = $request->input('rs_codigo');
        $fechaVencimiento = $request->input('rs_fecha_vencimiento');
        $descripcion = $request->input('rs_descripcion');


        $registroEntity = new RegistroSanitarioEntity($id, $codigo, $fechaVencimiento, $descripcion);

        return response()->json($this->updateRegistroSanitarioAdapter->updateRegistro($registroEntity));
    }
    public function deleteRegistro($idRegistroSanitario)
    {
        return response()->json($this->deleteRegistroSanitarioAdapter->deleteRegistro($idRegistroSanitario));
    }
}
