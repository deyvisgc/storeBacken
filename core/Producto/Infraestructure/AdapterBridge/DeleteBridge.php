<?php


namespace Core\Producto\Infraestructure\AdapterBridge;


use Core\Producto\Aplication\UseCases\CreateCase;
use Core\Producto\Aplication\UseCases\DeleteCase;
use Core\Producto\Aplication\UseCases\ReadCase;
use Core\Producto\Infraestructure\DataBase\ProductoSql;
use Illuminate\Http\Request;

class DeleteBridge
{
    /**
     * @var ProductoSql
     */
    private ProductoSql $productoSql;

    public function __construct(ProductoSql $productoSql)
    {
        $this->productoSql = $productoSql;
    }
    public function __invokexid(int $idproducto)
    {
        $readcase= new DeleteCase($this->productoSql);
        return $readcase->__invokexid($idproducto);
    }
}
