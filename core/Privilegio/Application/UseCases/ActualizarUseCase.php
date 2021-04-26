<?php


namespace Core\Privilegio\Application\UseCases;


use Core\Privilegio\Domain\Repositories\PrivilegioRepository;

class ActualizarUseCase
{
    /**
     * @var PrivilegioRepository
     */
    private PrivilegioRepository $privilegioRepository;

    public function __construct(PrivilegioRepository $privilegioRepository)
    {
        $this->privilegioRepository = $privilegioRepository;
    }
    function updatePrivilegio($idPrivilegio,$nombre, $acceso, $icon, $idPadre, $grupo) {
      return $this->privilegioRepository->updatePrivilegio($idPrivilegio, $nombre, $acceso, $icon, $idPadre, $grupo);
    }
    function changeStatusGrupo($data) {
        return $this->privilegioRepository->changeStatusGrupo($data);
    }
}
