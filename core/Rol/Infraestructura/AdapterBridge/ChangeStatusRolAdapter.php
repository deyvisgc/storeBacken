<?php


namespace Core\Rol\Infraestructura\AdapterBridge;


use Core\Rol\Application\UseCases\ChangeStatusRolUseCase;
use Core\Rol\Infraestructura\DataBase\RolRepositoryImpl;

class ChangeStatusRolAdapter
{
    /**
     * @var RolRepositoryImpl
     */
    private RolRepositoryImpl $rolRepositoryImpl;

    public function __construct(RolRepositoryImpl $rolRepositoryImpl)
    {
        $this->rolRepositoryImpl = $rolRepositoryImpl;
    }

    public function changeStatusRol(int $idRol) {
        $rol = new ChangeStatusRolUseCase($this->rolRepositoryImpl);
        return $rol->changeStatusRol($idRol);
    }
}
