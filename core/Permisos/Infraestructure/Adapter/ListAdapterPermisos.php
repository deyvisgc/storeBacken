<?php


namespace Core\Permisos\Infraestructure\Adapter;


use Core\Permisos\Aplication\UseCase\ListUseCasePermisos;
use Core\Permisos\Infraestructure\DataBase\PermisosSql;

class ListAdapterPermisos
{
    /**
     * @var PermisosSql
     */
    private PermisosSql $permisos;

    public function __construct(PermisosSql $permisosSql)
    {
        $this->permisos = $permisosSql;
    }
    function ListPermisos() {
        $listCase = new ListUseCasePermisos($this->permisos);
        return $listCase->ListPermisos();
    }
}
