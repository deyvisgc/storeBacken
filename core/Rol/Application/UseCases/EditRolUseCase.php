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
        $responseDB = $this->rolRepository->editRol($rolEntity);
        if ($responseDB === 1) {
            return response()->json(['status' => true, 'code' => 200, 'message' => 'Rol editado']);
        } else {
            return response()->json(['status' => false, 'code' => 400, 'message' => 'Rol no editado']);
        }
    }
}
