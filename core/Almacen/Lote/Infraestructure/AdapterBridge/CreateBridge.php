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
        $accion=$request->input('accion');
        $lot_name=$request->input('lot_name');
        $lot_codigo=$request->input('lot_codigo');
        $lot_expiration_date=$request->input('lot_expiration_date');
        $lot_creation_date=$request->input('lot_creation_date');
        $createProducto= new CreateCase($this->lotesql);
      return  $createProducto->__invoke($accion, $lot_name, $lot_codigo, $lot_expiration_date, $lot_creation_date);
    }
}
