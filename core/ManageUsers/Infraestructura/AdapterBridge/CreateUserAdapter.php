<?php


namespace Core\ManageUsers\Infraestructura\AdapterBridge;


use Core\ManagePerson\Domain\Entity\PersonEntity;
use Core\ManageUsers\Application\UseCases\CreateUserUseCase;
use Core\ManageUsers\Domain\Entity\UserEntity;
use Core\ManageUsers\Infraestructura\DataBase\UserRepositoryImpl;

class CreateUserAdapter
{
    /**
     * @var UserRepositoryImpl
     */
    private UserRepositoryImpl $userRepositoryImpl;

    public function __construct(UserRepositoryImpl $userRepositoryImpl)
    {
        $this->userRepositoryImpl = $userRepositoryImpl;
    }

    public function createUser(UserEntity $userEntity, PersonEntity $personEntity) {
        $user = new CreateUserUseCase($this->userRepositoryImpl);
        return $user->createUser($userEntity, $personEntity);
    }
}
