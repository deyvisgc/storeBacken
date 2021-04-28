<?php


namespace App\Http\Controllers\Permisos;


use App\Http\Controllers\Controller;
use Core\Permisos\Infraestructure\Adapter\CreateAdapterPermisos;
use Core\Permisos\Infraestructure\Adapter\DeleteAdapterPermisos;
use Core\Permisos\Infraestructure\Adapter\ListAdapterPermisos;
use Illuminate\Http\Request;

class PermisosController extends Controller
{
    /**
     * @var CreateAdapterPermisos
     */
    private CreateAdapterPermisos $createAdapterPermisos;
    /**
     * @var ListAdapterPermisos
     */
    private ListAdapterPermisos $listAdapterPermisos;
    private DeleteAdapterPermisos $deleteAdapterPermisos;
    public function __construct(CreateAdapterPermisos $createAdapterPermisos, ListAdapterPermisos $listAdapterPermisos,
                                DeleteAdapterPermisos  $deleteAdapterPermisos)
     {
         $this->middleware('auth');
         $this->createAdapterPermisos = $createAdapterPermisos;
         $this->listAdapterPermisos = $listAdapterPermisos;
         $this->deleteAdapterPermisos = $deleteAdapterPermisos;
     }
     function AddPermisos(Request $request) {
         return response()->json($this->createAdapterPermisos->AddPermisos($request->permisos));
     }
     function ListPermisos() {
        return response()->json($this->listAdapterPermisos->ListPermisos());
     }
     function DeletePermisos(Request $request) {
         return response()->json($this->deleteAdapterPermisos->delete($request));

     }

}
