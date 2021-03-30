<?php


namespace Core\ManageUsers\Application\UseCases;


use Core\ManageUsers\Domain\Repositories\UserRepository;

class GetUserByIdPersonUseCase
{
    /**
     * @var UserRepository
     */
    private UserRepository $userRepository;

    public function __construct(UserRepository $userRepository)
    {
        $this->userRepository = $userRepository;
    }

    public function getUserInfoByIdPerson(int $idPerson): \Illuminate\Http\JsonResponse
    {
        if ($idPerson <= 0) {
            return response()->json(['status' => false, 'code' => 400, 'message' => 'Usuario no encontrado']);
        }

        $user = $this->userRepository->getUserByIdPerson($idPerson);

        if ($user->count() > 0) {
            return response()->json(['status' => true, 'code' => 200, 'message' => 'Usuario encontrado', 'user' => $user[0]]);
        } else {
            return response()->json(['status' => false, 'code' => 400, 'message' => 'Usuario no encontrado']);
        }
    }
}
