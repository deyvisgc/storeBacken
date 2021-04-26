<?php


namespace Core\Rol\Application\UseCases;


use Core\Rol\Domain\Repositories\RolRepository;

class ChangeStatusRolUseCase
{
    /**
     * @var RolRepository
     */
    private RolRepository $rolRepository;

    public function __construct(RolRepository $rolRepository)
    {
        $this->rolRepository = $rolRepository;
    }

    public function changeStatusRol(int $idRol, string $status) {
        return $this->rolRepository->changeStatusRol($idRol, $status);
    }
}
