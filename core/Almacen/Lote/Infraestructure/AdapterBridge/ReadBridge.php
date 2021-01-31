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
    public function __invoke()
    {
        $readcase= new ReadCase($this->lotesql);
        return $readcase->__invoke();
    }
    public function __invokexid(int $idproducto)
    {
        $readcase= new ReadCase($this->lotesql);
        return $readcase->__invokexid($idproducto);
    }
}
