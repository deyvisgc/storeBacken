<?php


namespace Core\Producto\Infraestructure\AdapterBridge;


use Core\Producto\Aplication\UseCases\CreateCase;
use Core\Producto\Aplication\UseCases\ReadCase;
use Core\Producto\Infraestructure\DataBase\ProductoSql;
use Illuminate\Http\Request;

class ReadBridge
{
    /**
     * @var ProductoSql
     */
    private ProductoSql $productoSql;

    public function __construct(ProductoSql $productoSql)
    {
        $this->productoSql = $productoSql;
    }
    public function __invoke($params)
    {
        $readcase= new ReadCase($this->productoSql);
        return $readcase->__invoke($params);
    }
    public function Edit($params)
    {
        $readcase= new ReadCase($this->productoSql);
        return $readcase->Edit($params);
    }
    public function __invokeLastId() {
        $readcase= new ReadCase($this->productoSql);
        return $readcase->__invokeLastId();
    }
}
