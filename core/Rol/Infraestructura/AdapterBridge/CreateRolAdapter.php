<?php


namespace Core\Rol\Infraestructura\AdapterBridge;


use Core\Rol\Application\UseCases\CreateRolUseCase;
use Core\Rol\Domain\Entity\RolEntity;
use Core\Rol\Infraestructura\DataBase\RolRepositoryImpl;

class CreateRolAdapter
{
    /**
     * @var RolRepositoryImpl
     */
    private RolRepositoryImpl $rolRepositoryImpl;

    public function __construct(RolRepositoryImpl $rolRepositoryImpl)
    {
        $this->rolRepositoryImpl = $rolRepositoryImpl;
    }

    public function createRol(RolEntity $rolEntity){
        $rol = new CreateRolUseCase($this->rolRepositoryImpl);
        return $rol->createRol($rolEntity);
    }
}
