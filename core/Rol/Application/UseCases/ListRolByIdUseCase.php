<?php


namespace Core\Rol\Application\UseCases;


use Core\Rol\Domain\Repositories\RolRepository;

class ListRolByIdUseCase
{
    /**
     * @var RolRepository
     */
    private RolRepository $rolRepository;

    public function __construct(RolRepository $rolRepository)
    {
        $this->rolRepository = $rolRepository;
    }

    public function listRolById(int $idRol) {
        return $this->rolRepository->listRolById($idRol);
    }
}
