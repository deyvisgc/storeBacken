<?php


namespace Core\Privilegio\Infraestructura\AdapterBridge;


use Core\Privilegio\Application\UseCases\ListPrivilegesUseCase;
use Core\Privilegio\Infraestructura\DataBase\PrivilegiosRepositoryImpl;

class ListPrivilegesAdapter
{
    /**
     * @var PrivilegiosRepositoryImpl
     */
    private PrivilegiosRepositoryImpl $privilegiosRepositoryImpl;

    public function __construct(PrivilegiosRepositoryImpl $privilegiosRepositoryImpl)
    {
        $this->privilegiosRepositoryImpl = $privilegiosRepositoryImpl;
    }

    public function listPrivileges()
    {
        $listPrivileges = new ListPrivilegesUseCase($this->privilegiosRepositoryImpl);
        return $listPrivileges->listPrivileges();
    }
}
