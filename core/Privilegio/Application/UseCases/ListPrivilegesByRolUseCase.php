<?php


namespace Core\Privilegio\Application\UseCases;


use Core\Privilegio\Domain\Repositories\PrivilegioRepository;

class ListPrivilegesByRolUseCase
{
    /**
     * @var PrivilegioRepository
     */
    private PrivilegioRepository $privilegioRepository;

    public function __construct(PrivilegioRepository $privilegioRepository)
    {

        $this->privilegioRepository = $privilegioRepository;
    }
}
