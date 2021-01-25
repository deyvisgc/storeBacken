<?php


namespace Core\Rol\Application\UseCases;


use Core\Rol\Domain\Entity\RolEntity;
use Core\Rol\Domain\Repositories\RolRepository;

class CreateRolUseCase
{
    /**
     * @var RolRepository
     */
    private RolRepository $rolRepository;

    public function __construct(RolRepository $rolRepository)
    {
        $this->rolRepository = $rolRepository;
    }

    public function createRol(RolEntity $rolEntity)
    {
        return $this->rolRepository->createRol($rolEntity);
    }

}
