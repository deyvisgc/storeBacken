<?php


namespace Core\Rol\Infraestructura\AdapterBridge;


use Core\Rol\Application\UseCases\EditRolUseCase;
use Core\Rol\Domain\Entity\RolEntity;
use Core\Rol\Infraestructura\DataBase\RolRepositoryImpl;

class EditRolAdapter
{
    /**
     * @var RolRepositoryImpl
     */
    private RolRepositoryImpl $rolRepositoryImpl;

    public function __construct(RolRepositoryImpl $rolRepositoryImpl)
    {
        $this->rolRepositoryImpl = $rolRepositoryImpl;
    }

    public function editRol(RolEntity $rolEntity)
    {
        $editRol = new EditRolUseCase($this->rolRepositoryImpl);
        return $editRol->editRol($rolEntity);
    }
}
