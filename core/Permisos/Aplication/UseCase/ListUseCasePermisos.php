<?php


namespace Core\Permisos\Aplication\UseCase;


use Core\Permisos\Domain\Interfaces\PermisosInterface;
use Core\Permisos\Infraestructure\DataBase\PermisosSql;

class ListUseCasePermisos
{
    public function __construct(PermisosInterface $permisos)
    {
        $this->permisos = $permisos;
    }

    function ListPermisos() {
        return $this->permisos->List();
    }
}
