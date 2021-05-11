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
    function getUserByIdPerson(int $idUsers) {
        $user = new GetUserByIdPersonUseCase($this->userRepositoryImpl);
        return $user->getUserByIdPerson($idUsers);
    }
    function SearchUser(string $params)
    {
        $user = new GetUserByIdPersonUseCase($this->userRepositoryImpl);
        return $user->SearchUser($params);
    }
}
