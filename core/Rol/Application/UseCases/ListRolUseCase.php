<?php


namespace Core\Rol\Application\UseCases;


use Core\Rol\Domain\Repositories\RolRepository;

class ListRolUseCase
{
    /**
     * @var RolRepository
     */
    private RolRepository $rolRepository;

    public function __construct(RolRepository $rolRepository)
    {
        $this->rolRepository = $rolRepository;
    }

    public function listRol()
    {
        return $this->rolRepository->listRol();
    }
}
