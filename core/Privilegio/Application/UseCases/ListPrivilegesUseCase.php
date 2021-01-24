<?php


namespace Core\Privilegio\Application\UseCases;


use Core\Privilegio\Domain\Repositories\PrivilegioRepository;

class
ListPrivilegesUseCase
{

    /**
     * @var PrivilegioRepository
     */
    private PrivilegioRepository $privilegioRepository;

    public function __construct(PrivilegioRepository $privilegioRepository)
    {
        $this->privilegioRepository = $privilegioRepository;
    }

    public function listPrivileges()
    {
        return $this->privilegioRepository->listPrivileges();
    }
}
