<?php


namespace Core\Rol\Infraestructura\AdapterBridge;


use Core\Rol\Application\UseCases\ListRolUseCase;
use Core\Rol\Infraestructura\DataBase\RolRepositoryImpl;

class ListRolAdapter
{
    /**
     * @var RolRepositoryImpl
     */
    private RolRepositoryImpl $rolRepositoryImpl;

    public function __construct(RolRepositoryImpl $rolRepositoryImpl)
    {
        $this->rolRepositoryImpl = $rolRepositoryImpl;
    }

    public function listRol()
    {
        $listRol = new ListRolUseCase($this->rolRepositoryImpl);
        return $listRol->listRol();
    }
}
