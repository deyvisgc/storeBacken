<?php


namespace Core\Almacen\Unidad\Infraestructure\AdapterBridge;


use Core\Almacen\Unidad\Aplication\UseCases\DeleteCase;
use Core\Almacen\Unidad\Infraestructure\DataBase\UnidadSql;

class DeleteBridge
{


    /**
     * @var UnidadSql
     */
    private UnidadSql $unidadSql;

    public function __construct(UnidadSql $unidadSql)
    {
        $this->unidadSql = $unidadSql;
    }
    public function __invokexid(int $idproducto)
    {
        $readcase= new DeleteCase($this->unidadSql);
        return $readcase->__invokexid($idproducto);
    }
}
