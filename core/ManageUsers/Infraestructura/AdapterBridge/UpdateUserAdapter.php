<?php


namespace Core\ManageUsers\Infraestructura\AdapterBridge;


use Core\ManageUsers\Application\UseCases\UpdateUserUseCase;
use Core\ManageUsers\Domain\Entity\UserEntity;
use Core\ManageUsers\Infraestructura\DataBase\UserRepositoryImpl;

class UpdateUserAdapter
{
    /**
     * @var UserRepositoryImpl
     */
    private UserRepositoryImpl $userRepositoryImpl;

    public function __construct(UserRepositoryImpl $userRepositoryImpl)
    {
        $this->userRepositoryImpl = $userRepositoryImpl;
    }

    public function updateUser(UserEntity $userEntity) {
        $user = new UpdateUserUseCase($this->userRepositoryImpl);
        return $user->editUser($userEntity);
    }
}
