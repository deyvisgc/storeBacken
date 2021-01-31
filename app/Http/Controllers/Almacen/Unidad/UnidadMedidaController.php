<?php

namespace App\Http\Controllers\Almacen\Unidad;

use App\Http\Controllers\Controller;
use Core\Almacen\Unidad\Infraestructure\AdapterBridge\CreateBridge;
use Core\Almacen\Unidad\Infraestructure\AdapterBridge\DeleteBridge;
use Core\Almacen\Unidad\Infraestructure\AdapterBridge\ReadBridge;
use Core\Almacen\Unidad\Infraestructure\AdapterBridge\UpdateBridge;
use Illuminate\Http\Request;

class UnidadMedidaController extends Controller
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
    }
    public function Read() {
        return response()->json($this->readBridge->__invoke());
    }
}
