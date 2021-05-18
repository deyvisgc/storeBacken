<?php

namespace App\Http\Controllers\Almacen\Lote;

use App\Http\Controllers\Controller;
use Core\Almacen\Lote\Infraestructure\AdapterBridge\CreateBridge;
use Core\Almacen\Lote\Infraestructure\AdapterBridge\DeleteBridge;
use Core\Almacen\Lote\Infraestructure\AdapterBridge\ReadBridge;
use Core\Almacen\Lote\Infraestructure\AdapterBridge\UpdateBridge;
use Illuminate\Http\Request;

class LoteController extends Controller
{
    /**
     * @var CreateBridge
     */
    private CreateBridge $createBridge;
    /**
     * @var UpdateBridge
     */
    private UpdateBridge $updateBridge;
    /**
     * @var ReadBridge
     */
    private ReadBridge $readBridge;
    /**
     * @var DeleteBridge
     */
    private DeleteBridge $deleteBridge;


    public function __construct(CreateBridge $createBridge, UpdateBridge $updateBridge, ReadBridge $readBridge, DeleteBridge $deleteBridge)
    {
        $this->createBridge = $createBridge;
        $this->updateBridge = $updateBridge;
        $this->readBridge = $readBridge;
        $this->deleteBridge =$deleteBridge;
        $this->middleware('auth');
    }
     function getLotes(Request $request) {
        return response()->json($this->readBridge->__invoke($request));
    }
     function SearchLotes(Request $request) {
        return response()->json($this->readBridge->SearchLotes($request->params));
    }
    public function store(Request $request) {

        return response()->json($this->createBridge->__invoke($request));
    }
    public function update(Request $request) {

        return response()->json($this->updateBridge->__invoke($request));
    }
    public function delete($id) {

        return response()->json($this->deleteBridge->__invokexid($id));
    }
    public function ChangestatusLote(Request $request) {
        return response()->json($this->updateBridge->__changestatus($request));
    }

}
