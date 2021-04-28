<?php


namespace Core\Permisos\Infraestructure\Adapter;


use Core\Permisos\Aplication\UseCase\DeleteUseCasePermisos;
use Core\Permisos\Infraestructure\DataBase\PermisosSql;

class DeleteAdapterPermisos
{
    public function __construct(PermisosSql $permisosSql)
    {
        $this->permisos = $permisosSql;
    }
    function delete($data) {
        $idPermisos= $data['idPermisos'];
        $deleteUseCase = new DeleteUseCasePermisos($this->permisos);
        return $deleteUseCase->delete($idPermisos);
    }
}
