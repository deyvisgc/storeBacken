<?php


namespace Core\Almacen\Clase\Infraestructure\AdapterBridge;


use Core\Almacen\Clase\Infraestructure\DataBase\ClaseSql;
use Core\Producto\Aplication\UseCases\DeleteCase;


class DeleteBridge
{


    /**
     * @var ClaseSql
     */
    private ClaseSql $clase;

    public function __construct(ClaseSql $claseSql)
    {
        $this->clase = $claseSql;
    }
}
