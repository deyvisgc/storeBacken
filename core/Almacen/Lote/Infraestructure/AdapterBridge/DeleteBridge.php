<?php


namespace Core\Almacen\Lote\Infraestructure\AdapterBridge;


use Core\Almacen\Lote\Aplication\UseCases\DeleteCase;
use Core\Almacen\Lote\Infraestructure\DataBase\LoteSql;



class DeleteBridge
{


    /**
     * @var LoteSql
     */
    private LoteSql $productoSql;

    public function __construct(LoteSql $loteSql)
    {
        $this->productoSql = $loteSql;
    }
    public function __invokexid(int $id)
    {
        $readcase= new DeleteCase($this->productoSql);
        return $readcase->__invokexid($id);
    }
}
