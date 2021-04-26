<?php


namespace Core\Privilegio\Infraestructura\AdapterBridge;


use Core\Privilegio\Application\UseCases\DeleteUseCase;
use Core\Privilegio\Infraestructura\DataBase\PrivilegiosRepositoryImpl;

class DeletePrivilegios
{
    /**
     * @var PrivilegiosRepositoryImpl
     */
    private PrivilegiosRepositoryImpl $repositoryImpl;

    public function __construct(PrivilegiosRepositoryImpl $repositoryImpl)
    {
        $this->repositoryImpl = $repositoryImpl;
    }
    function EliminarPrivilegioGrupo($request) {
        $idPadre = $request['idPadre'];
        $idPrivilegio = $request['idPrivlegio'];
        $deletUseCase = new DeleteUseCase($this->repositoryImpl);
        return $deletUseCase->eliminarPrivilegioGrupo($idPadre, $idPrivilegio);
    }
}
