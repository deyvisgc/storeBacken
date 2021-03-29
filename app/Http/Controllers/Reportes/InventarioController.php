<?php


namespace App\Http\Controllers\Reportes;


use App\Http\Controllers\Controller;
use Core\Reportes\Infraestructure\Adapter\InventarioAdapter;
use Illuminate\Http\Request;

class InventarioController extends Controller
{
    /**
     * @var InventarioAdapter
     */
    private InventarioAdapter $inventarioAdapter;

    public function __construct(InventarioAdapter $inventarioAdapter)
    {
        $this->inventarioAdapter = $inventarioAdapter;
    }

    public function Inventario(Request $request)
    {
        return response()->json($this->inventarioAdapter->__Inventario($request));
    }
}
