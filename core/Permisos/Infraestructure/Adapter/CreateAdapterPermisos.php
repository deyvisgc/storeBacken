<?php


namespace Core\Permisos\Infraestructure\Adapter;


use Core\Permisos\Aplication\UseCase\CreateUseCasePermisos;
use Core\Permisos\Infraestructure\DataBase\PermisosSql;

class CreateAdapterPermisos
{
    /**
     * @var PermisosSql
     */
    private PermisosSql $permisos;

    public function __construct(PermisosSql $permisosSql)
    {
        $this->permisos = $permisosSql;
    }
    function AddPermisos($data) {
        $rol = $data['rol'];
        $privilegios = $data['idPrivilegio'];
        $createCase = new CreateUseCasePermisos($this->permisos);
        return $createCase->AddPrivilegios($rol, $privilegios);
    }
}
