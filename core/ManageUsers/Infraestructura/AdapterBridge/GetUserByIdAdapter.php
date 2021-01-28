<?php


namespace Core\ManageUsers\Infraestructura\AdapterBridge;


use Core\ManageUsers\Application\UseCases\GetUserByIdUseCase;
use Core\ManageUsers\Infraestructura\DataBase\UserRepositoryImpl;

class GetUserByIdAdapter
{
    /**
     * @var UserRepositoryImpl
     */
    private UserRepositoryImpl $userRepositoryImpl;

    public function __construct(UserRepositoryImpl $userRepositoryImpl)
    {
        $this->userRepositoryImpl = $userRepositoryImpl;
    }

    public function getUserById(int $idUser) {
        $user = new GetUserByIdUseCase($this->userRepositoryImpl);
        return $user->getUserById($idUser);
    }
}
