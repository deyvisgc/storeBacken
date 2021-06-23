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
     function __invoke($params)
    {
        $readcase= new ReadCase($this->productoSql);
        return $readcase->__invoke($params);
    }
     function Edit($params)
    {
        $readcase= new ReadCase($this->productoSql);
        return $readcase->Edit($params);
    }
     function __invokeLastId() {
        $readcase= new ReadCase($this->productoSql);
        return $readcase->__invokeLastId();
    }
     function search($params) {
        $readcase= new ReadCase($this->productoSql);
        return $readcase->search($params);
    }
     function selectProducto($params)
    {
        $readcase= new ReadCase($this->productoSql);
        return $readcase->selectProducto($params);
    }
}
