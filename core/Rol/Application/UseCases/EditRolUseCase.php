<?php


namespace Core\Rol\Application\UseCases;


use Core\Rol\Domain\Entity\RolEntity;
use Core\Rol\Domain\Repositories\RolRepository;

class EditRolUseCase
{
    /**
     * @var RolRepository
     */
    private RolRepository $rolRepository;

    public function __construct(RolRepository $rolRepository)
    {
        $this->rolRepository = $rolRepository;
    }

    public function editRol(RolEntity $rolEntity) {
        return $this->rolRepository->editRol($rolEntity);

    }
}
