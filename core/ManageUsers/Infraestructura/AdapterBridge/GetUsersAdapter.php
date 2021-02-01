<?php


namespace Core\ManageUsers\Infraestructura\AdapterBridge;


use Core\ManageUsers\Application\UseCases\GetUsersUseCase;
use Core\ManageUsers\Infraestructura\DataBase\UserRepositoryImpl;

class GetUsersAdapter
{
    /**
     * @var UserRepositoryImpl
     */
    private UserRepositoryImpl $userRepositoryImpl;

    public function __construct(UserRepositoryImpl $userRepositoryImpl)
    {
        $this->userRepositoryImpl = $userRepositoryImpl;
    }

    public function getUser() {
        $user = new GetUsersUseCase($this->userRepositoryImpl);
        return $user->getUsers();
    }
}
