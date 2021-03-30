<?php


namespace Core\Privilegio\Infraestructura\AdapterBridge;


use Core\Privilegio\Application\UseCases\ListPrivilegesByRolUseCase;
use Core\Privilegio\Infraestructura\DataBase\PrivilegiosRepositoryImpl;

class ListPrivilegesByRolAdapter
{
    /**
     * @var PrivilegiosRepositoryImpl
     */
    private PrivilegiosRepositoryImpl $privilegiosRepositoryImpl;

    public function __construct(PrivilegiosRepositoryImpl $privilegiosRepositoryImpl)
    {
        $this->privilegiosRepositoryImpl = $privilegiosRepositoryImpl;
    }

    public function listPrivilegesByRol($idRol) {
        $listPrivilegesByRol = new ListPrivilegesByRolUseCase($this->privilegiosRepositoryImpl);
        return $listPrivilegesByRol->listPrivilegesByRol($idRol);
    }
}
