<?php


namespace Core\ManageUsers\Application\UseCases;


use Core\ManageUsers\Domain\Entity\UserEntity;
use Core\ManageUsers\Domain\Repositories\UserRepository;

class UpdateUserUseCase
{
    /**
     * @var UserRepository
     */
    private UserRepository $userRepository;

    public function __construct(UserRepository $userRepository)
    {
        $this->userRepository = $userRepository;
    }

    public function editUser(UserEntity $userEntity): \Illuminate\Http\JsonResponse
    {
        $responseDB = $this->userRepository->editUser($userEntity);

        if ($responseDB === 0) {
            return response()->json(['status' => true, 'code' => 200, 'message' => 'Datos usuario actualizado']);
        } else {
            return response()->json(['status' => false, 'code' => 400, 'message' => 'Datos usuario no actualizados']);
        }
    }
}
