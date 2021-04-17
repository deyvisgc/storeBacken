<?php


namespace Core\ManageUsers\Infraestructura\AdapterBridge;


use Core\ManageUsers\Application\UseCases\GetUserByIdPersonUseCase;
use Core\ManageUsers\Infraestructura\DataBase\UserRepositoryImpl;

class GetUserByIdPersonAdapter
{
    /**
     * @var UserRepositoryImpl
     */
    private UserRepositoryImpl $userRepositoryImpl;

    public function __construct(UserRepositoryImpl $userRepositoryImpl)
    {
        $this->userRepositoryImpl = $userRepositoryImpl;
    }

    public function getUserInfoByIdPerson(int $idPerson): \Illuminate\Http\JsonResponse
    {
        $user = new GetUserByIdPersonUseCase($this->userRepositoryImpl);
        return $user->getUserInfoByIdPerson($idPerson);
    }
}
