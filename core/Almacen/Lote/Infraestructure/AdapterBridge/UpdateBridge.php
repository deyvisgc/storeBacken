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
        $id=$request->input('idlote');
        $accion=$request->input('accion');
        $lot_name=$request->input('lot_name');
        $lot_codigo=$request->input('lot_codigo');
        $lot_expiration_date=$request->input('lot_expiration_date');
        $lot_creation_date=$request->input('lot_creation_date');
        $createProducto= new UpdateCase($this->loteSql);
        return  $createProducto->__invoke($accion, $lot_name, $lot_codigo, $lot_expiration_date, $lot_creation_date,$id);
    }
}
