<?php


namespace Core\Privilegio\Infraestructura\AdapterBridge;


use Core\Privilegio\Application\UseCases\CreateUseCase;
use Core\Privilegio\Infraestructura\DataBase\PrivilegiosRepositoryImpl;

class CreatePrivilegioAdapter
{
    /**
 * @var PrivilegiosRepositoryImpl
 */
    private PrivilegiosRepositoryImpl $repositoryImpl;

    public function __construct(PrivilegiosRepositoryImpl $repositoryImpl)
    {
        $this->repositoryImpl = $repositoryImpl;
    }
    function guardarPrivilegio ($data) {
        $nombre = $data['nombre'];
        $acceso = $data['acceso'];
        $icon  = $data['icon'];
        $idPadre = $data['idPadre'];
        $grupo  = $data['grupo'];
        $createUseCase = new CreateUseCase($this->repositoryImpl);
      return  $createUseCase->addGrupo($nombre, $acceso, $icon, $idPadre, $grupo);
    }
}
