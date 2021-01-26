<?php


namespace Core\Rol\Infraestructura\AdapterBridge;


use Core\Rol\Application\UseCases\DeleteRolUseCase;
use Core\Rol\Infraestructura\DataBase\RolRepositoryImpl;

class DeleteRolAdapter
{
    /**
     * @var RolRepositoryImpl
     */
    private RolRepositoryImpl $rolRepositoryImpl;

    public function __construct(RolRepositoryImpl $rolRepositoryImpl)
    {
        $this->rolRepositoryImpl = $rolRepositoryImpl;
    }

    public function deleteRol($idRol){
        $rol = new DeleteRolUseCase($this->rolRepositoryImpl);
        return $rol->deleteRol($idRol);
    }
}
