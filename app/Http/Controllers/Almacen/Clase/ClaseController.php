<?php

namespace App\Http\Controllers\Almacen\Clase;

use App\Http\Controllers\Controller;
use Core\Almacen\Clase\Infraestructure\AdapterBridge\CreateBridge;
use Core\Almacen\Clase\Infraestructure\AdapterBridge\DeleteBridge;
use Core\Almacen\Clase\Infraestructure\AdapterBridge\ReadBridge;
use Core\Almacen\Clase\Infraestructure\AdapterBridge\UpdateBridge;
use Illuminate\Http\Request;

class ClaseController extends Controller
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
