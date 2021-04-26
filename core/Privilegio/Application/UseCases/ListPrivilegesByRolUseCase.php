<?php


namespace Core\Privilegio\Application\UseCases;

define('KEY_PASSWORD_TO_DECRYPT','K56QSxGeKImwBRmiYoP');
use Core\Privilegio\Domain\Repositories\PrivilegioRepository;
use Core\Traits\EncryptTrait;

class ListPrivilegesByRolUseCase
{
    use EncryptTrait;
    /**
     * @var PrivilegioRepository
     */
    private PrivilegioRepository $privilegioRepository;

    public function __construct(PrivilegioRepository $privilegioRepository)
    {
        $this->privilegioRepository = $privilegioRepository;
    }

     function listPrivilegesByRol($idRol) {
        return $this->privilegioRepository->listPrivilegesByRol($idRol);
    }
    function getGrupos() {
        return $this->privilegioRepository->getGrupos();
    }
    function getGruposDetalle($id) {
        return $this->privilegioRepository->getGruposDetalle($id);
    }
    function getPrivilegios() {
        return $this->privilegioRepository->getPrivilegios();
    }
}
