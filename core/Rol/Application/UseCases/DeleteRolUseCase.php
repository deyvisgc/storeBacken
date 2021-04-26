<?php


namespace Core\Rol\Application\UseCases;


use Core\Rol\Domain\Repositories\RolRepository;

class DeleteRolUseCase
{
    /**
     * @var RolRepository
     */
    private RolRepository $rolRepository;

    public function __construct(RolRepository $rolRepository)
    {
        $this->rolRepository = $rolRepository;
    }

    public function deleteRol($idRol) {
        return $this->rolRepository->deleteRol($idRol);

    }
}
