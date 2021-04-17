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
        $responseDB = $this->rolRepository->deleteRol($idRol);
        if ($responseDB === 1) {
            return response()->json(['status' => true, 'code' => 200, 'message' => 'Rol deshabilitado']);
        } else {
            return response()->json(['status' => false, 'code' => 400, 'message' => 'No se hizo nada']);
        }
    }
}
