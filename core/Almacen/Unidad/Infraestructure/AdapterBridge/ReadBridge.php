<?php


namespace Core\Almacen\Unidad\Infraestructure\AdapterBridge;


use Core\Almacen\Unidad\Aplication\UseCases\ReadCase;
use Core\Almacen\Unidad\Infraestructure\DataBase\UnidadSql;


class ReadBridge
{

    /**
     * @var UnidadSql
     */
    private UnidadSql $unidadSql;

    public function __construct(UnidadSql $unidadSql)
    {

        $this->unidadSql = $unidadSql;
    }
     function __invoke($params)
    {
        $readcase= new ReadCase($this->unidadSql);
        return $readcase->__invoke($params);
    }
    function SearchUnidad($params) {
        $readcase= new ReadCase($this->unidadSql);
        return $readcase->SearchUnidad($params);
    }
     function __invokexid(int $idproducto)
    {
        $readcase= new ReadCase($this->unidadSql);
        return $readcase->__invokexid($idproducto);
    }
}
