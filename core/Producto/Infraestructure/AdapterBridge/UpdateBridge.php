<?php


namespace Core\Producto\Infraestructure\AdapterBridge;


use Core\Producto\Aplication\UseCases\UpdateCase;
use Core\Producto\Infraestructure\DataBase\ProductoSql;
use Illuminate\Http\Request;

class UpdateBridge
{
    /**
     * @var ProductoSql
     */
    private ProductoSql $productoSql;

    public function __construct(ProductoSql $productoSql)
    {
        $this->productoSql = $productoSql;
    }
    public function changestatus (Request $request) {

        $idproducto=$request['data'][0]['id'];
        $status=$request['data'][0]['status'];
        $update= new UpdateCase($this->productoSql);
        return $update->ChangeStatus($status,$idproducto);

    }
}
