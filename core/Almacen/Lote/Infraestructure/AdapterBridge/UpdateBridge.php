<?php


namespace Core\Almacen\Lote\Infraestructure\AdapterBridge;


use Core\Almacen\Lote\Aplication\UseCases\UpdateCase;
use Core\Almacen\Lote\Infraestructure\DataBase\LoteSql;
use Illuminate\Http\Request;

class UpdateBridge
{
    /**
     * @var LoteSql
     */
    private LoteSql $loteSql;

    public function __construct(LoteSql $loteSql)
    {
        $this->loteSql = $loteSql;
    }
    public function __invoke(Request $request)
    {
        $id=$request['data']['id_lote'];
        $lot_name=$request['data']['lote_update'];
        $lot_codigo=$request['data']['codigo_update'];
        $lot_creation_date=$request['data']['fecha_creacion_update'];
        $lot_expiration_date=$request['data']['fecha_expiracion_update'];
        $UpdateProducto= new UpdateCase($this->loteSql);
        return  $UpdateProducto->__invoke($lot_name, $lot_codigo, $lot_expiration_date, $lot_creation_date,$id);
    }
    public function __changestatus(Request $request) {
        $id=$request['data']['id_lote'];
        $status=$request['data']['lot_status'];
        $UpdateProducto= new UpdateCase($this->loteSql);
        return $UpdateProducto->ChangeStatus($id, $status);
    }
}
