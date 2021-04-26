<?php


namespace Core\Privilegio\Infraestructura\AdapterBridge;


use Core\Privilegio\Application\UseCases\CreateUseCase;
use Core\Privilegio\Application\UseCases\ListPrivilegesByRolUseCase;
use Core\Privilegio\Infraestructura\DataBase\PrivilegiosRepositoryImpl;
use Illuminate\Http\Request;

class ListPrivilegesByRolAdapter
{
    /**
     * @var PrivilegiosRepositoryImpl
     */
    private PrivilegiosRepositoryImpl $privilegiosRepositoryImpl;
    /**
     * @var CreatePrivilegioAdapter
     */
    private CreatePrivilegioAdapter $createUseCase;

    public function __construct(PrivilegiosRepositoryImpl $privilegiosRepositoryImpl)
    {
        $this->privilegiosRepositoryImpl = $privilegiosRepositoryImpl;
    }
     function listPrivilegesByRol($idRol) {
        $listPrivilegesByRol = new ListPrivilegesByRolUseCase($this->privilegiosRepositoryImpl);
        return $listPrivilegesByRol->listPrivilegesByRol($idRol);
    }

    function getGrupos() {
        $listPrivilegesByRol = new ListPrivilegesByRolUseCase($this->privilegiosRepositoryImpl);
        return $listPrivilegesByRol->getGrupos();
    }
    function getPrivilegios() {
        $listPrivilegesByRol = new ListPrivilegesByRolUseCase($this->privilegiosRepositoryImpl);
        return $listPrivilegesByRol->getPrivilegios();
    }
    function getGruposDetalle($idPrivilegio) {
        $listPrivilegesByRol = new ListPrivilegesByRolUseCase($this->privilegiosRepositoryImpl);
        return $listPrivilegesByRol->getGruposDetalle($idPrivilegio);
    }
}
