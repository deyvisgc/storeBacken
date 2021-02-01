<?php


namespace Core\ManageUsers\Infraestructura\AdapterBridge;


use Core\ManageUsers\Application\UseCases\DeleteUserUseCase;
use Core\ManageUsers\Infraestructura\DataBase\UserRepositoryImpl;

class DeleteUserAdapter
{
    /**
     * @var UserRepositoryImpl
     */
    private UserRepositoryImpl $userRepositoryImpl;

    public function __construct(UserRepositoryImpl $userRepositoryImpl)
    {
        $this->userRepositoryImpl = $userRepositoryImpl;
    }

    public function deleteUser(int $idUser) {
        $user = new DeleteUserUseCase($this->userRepositoryImpl);
        return $user->deleteUser($idUser);
    }
}
