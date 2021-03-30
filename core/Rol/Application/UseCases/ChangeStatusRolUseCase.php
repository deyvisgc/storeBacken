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

    public function changeStatusRol(int $idRol) {
        $responseDB = $this->rolRepository->changeStatusRol($idRol);
        if ($responseDB === 1) {
            return response()->json(['status' => true, 'code' => 200, 'message' => 'Rol habilitado']);
        } else {
            return response()->json(['status' => false, 'code' => 400, 'message' => 'Rol no habilitado']);
        }
    }
}
