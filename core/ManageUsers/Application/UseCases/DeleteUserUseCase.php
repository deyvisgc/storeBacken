<?php


namespace Core\ManageUsers\Application\UseCases;


use Core\ManageUsers\Domain\Repositories\UserRepository;

class DeleteUserUseCase
{
    /**
     * @var UserRepository
     */
    private UserRepository $userRepository;

    public function __construct(UserRepository $userRepository)
    {
        $this->userRepository = $userRepository;
    }

    public function deleteUser(int $idUser) {
        $responseDB = $this->userRepository->deleteUser($idUser);
        if ($responseDB === 1) {
            return response()->json(['status' => true, 'code' => 200, 'message' => 'Datos usuario eliminado']);
        } else {
            return response()->json(['status' => false, 'code' => 400, 'message' => 'Datos usuario eliminado']);
        }
    }
}
