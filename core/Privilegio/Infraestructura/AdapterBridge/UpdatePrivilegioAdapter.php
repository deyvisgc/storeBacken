<?php


namespace Core\Privilegio\Infraestructura\AdapterBridge;



use Core\Privilegio\Application\UseCases\ActualizarUseCase;
use Core\Privilegio\Infraestructura\DataBase\PrivilegiosRepositoryImpl;

class UpdatePrivilegioAdapter
{
    /**
     * @var PrivilegiosRepositoryImpl
     */
    private PrivilegiosRepositoryImpl $repositoryImpl;

    public function __construct(PrivilegiosRepositoryImpl $repositoryImpl)
    {
        $this->repositoryImpl = $repositoryImpl;
    }

    function updatePrivilegio ($data) {
        $nombre = $data['nombre'];
        $acceso = $data['acceso'];
        $icon  = $data['icon'];
        $idPadre = $data['idPadre'];
        $grupo  = $data['grupo'];
        $idPrivilegio = $data['idPrivilegio'];
        $actuaUseCase = new ActualizarUseCase($this->repositoryImpl);
        return  $actuaUseCase->updatePrivilegio($idPrivilegio,$nombre, $acceso, $icon, $idPadre, $grupo);
    }
    function changeStatusGrupo ($data) {
        $actuaUseCase = new ActualizarUseCase($this->repositoryImpl);
        return  $actuaUseCase->changeStatusGrupo($data);
    }
}
