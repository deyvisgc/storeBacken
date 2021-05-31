<?php


namespace Core\Almacen\Lote\Infraestructure\AdapterBridge;


use Core\Almacen\Lote\Aplication\UseCases\ReadCase;
use Core\Almacen\Lote\Infraestructure\DataBase\LoteSql;

class ReadBridge
{


    /**
     * @var LoteSql
     */
    private LoteSql $lotesql;

    public function __construct(LoteSql $loteSql)
    {
        $this->lotesql = $loteSql;
    }
     function __invoke($request)
    {
        $readcase= new ReadCase($this->lotesql);
        return $readcase->__invoke($request);
    }
    function obtenerCode($params) {
        $readcase= new ReadCase($this->lotesql);
        return $readcase->obtenerCode($params);
    }
    function SearchLotes($params) {
        $readcase= new ReadCase($this->lotesql);
        return $readcase->SearchLotes($params);
    }
     function getLoteXid(int $idproducto)
    {
        $readcase= new ReadCase($this->lotesql);
        return $readcase->__invokexid($idproducto);
    }
}
