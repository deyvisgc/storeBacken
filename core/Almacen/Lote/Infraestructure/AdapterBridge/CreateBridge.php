<?php


namespace Core\Almacen\Lote\Infraestructure\AdapterBridge;


use Core\Almacen\Lote\Aplication\UseCases\CreateCase;
use Core\Almacen\Lote\Infraestructure\DataBase\LoteSql;
use Illuminate\Http\Request;

class CreateBridge
{

    /**
     * @var LoteSql
     */
    private LoteSql $lotesql;

    public function __construct(LoteSql $loteSql)
    {
        $this->lotesql = $loteSql;
    }
    public function __invoke(Request $request)
    {
        $lot_name=$request['data']['lote'];
        $lot_codigo=$request['data']['codigo'];
        $lot_creation_date=$request['data']['fecha_creacion'];
        $lot_expiration_date=$request['data']['fecha_expiracion'];
        $createProducto= new CreateCase($this->lotesql);
      return  $createProducto->__invoke($lot_name, $lot_codigo, $lot_expiration_date, $lot_creation_date);
    }
}
