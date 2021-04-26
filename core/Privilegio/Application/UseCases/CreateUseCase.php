<?php


namespace Core\Privilegio\Application\UseCases;


use Core\Privilegio\Domain\Repositories\PrivilegioRepository;

class CreateUseCase
{
    /**
     * @var PrivilegioRepository
     */
    private PrivilegioRepository $privilegioRepository;

    public function __construct(PrivilegioRepository $privilegioRepository)
    {
        $this->privilegioRepository = $privilegioRepository;
    }
    function addGrupo($nombre, $acceso, $icon, $idPadre, $grupo) {
      return $this->privilegioRepository->AddPrivilegio($nombre, $acceso, $icon, $idPadre, $grupo);
    }
}
