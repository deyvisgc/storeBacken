<?php

namespace App\Http\Controllers\Almacen\Lote;

use App\Http\Controllers\Controller;
use App\Repository\Almacen\Lotes\LoteRepository;
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
    /**
     * @var LoteRepository
     */
    private LoteRepository $repository;


    public function __construct(CreateBridge $createBridge, UpdateBridge $updateBridge, ReadBridge $readBridge,
                                DeleteBridge $deleteBridge, LoteRepository $repository)
    {
        $this->createBridge = $createBridge;
        $this->updateBridge = $updateBridge;
        $this->readBridge = $readBridge;
        $this->deleteBridge =$deleteBridge;
        $this->repository = $repository;
        $this->middleware('auth');
    }
     function getLotes(Request $request) {
        return $this->repository->all($request);
    }
    function ObtenerCode(Request $request) {
        return response()->json($this->readBridge->obtenerCode($request));
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
     function ChangestatusLote(Request $request) {
        return response()->json($this->updateBridge->__changestatus($request));
    }
    function getLotesXid(int $id) {
        return response()->json($this->readBridge->getLoteXid($id));
    }

}
