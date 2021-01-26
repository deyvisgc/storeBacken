<?php


namespace Core\Rol\Infraestructura\AdapterBridge;


use Core\Rol\Application\UseCases\ListRolByIdUseCase;
use Core\Rol\Infraestructura\DataBase\RolRepositoryImpl;

class ListRolByIdAdapter
{
    /**
     * @var RolRepositoryImpl
     */
    private RolRepositoryImpl $rolRepositoryImpl;

    public function __construct(RolRepositoryImpl $rolRepositoryImpl)
    {
        $this->rolRepositoryImpl = $rolRepositoryImpl;
    }

    public function listRolById(int $idRol) {
        $rol = new ListRolByIdUseCase($this->rolRepositoryImpl);
        return $rol->listRolById($idRol);
    }
}
