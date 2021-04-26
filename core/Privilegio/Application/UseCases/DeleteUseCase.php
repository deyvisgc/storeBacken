<?php


namespace Core\Privilegio\Application\UseCases;


use Core\Privilegio\Domain\Repositories\PrivilegioRepository;

class DeleteUseCase
{
    /**
     * @var PrivilegioRepository
     */
    private PrivilegioRepository $privilegioRepository;

    public function __construct(PrivilegioRepository $privilegioRepository)
    {
        $this->privilegioRepository = $privilegioRepository;
    }
    function eliminarPrivilegioGrupo($idPadre, $idPrivilegio) {
        return $this->privilegioRepository->eliminarPrivilegioGrupo($idPadre, $idPrivilegio);
    }
}
