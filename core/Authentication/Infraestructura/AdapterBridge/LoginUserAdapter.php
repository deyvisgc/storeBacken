<?php


namespace Core\Authentication\Infraestructura\AdapterBridge;


use Core\Authentication\Application\UseCase\LoginUserUseCase;
use Core\Authentication\Infraestructura\Database\AuthenticationRepositoryImpl;
use Core\ManageUsers\Infraestructura\DataBase\UserRepositoryImpl;

class LoginUserAdapter
{
    /**
     * @var AuthenticationRepositoryImpl
     */
    private AuthenticationRepositoryImpl $authenticationRepositoryImpl;
    /**
     * @var UserRepositoryImpl
     */
    private UserRepositoryImpl $userRepositoryImpl;

    public function __construct(AuthenticationRepositoryImpl $authenticationRepositoryImpl, UserRepositoryImpl $userRepositoryImpl)
    {
        $this->authenticationRepositoryImpl = $authenticationRepositoryImpl;
        $this->userRepositoryImpl = $userRepositoryImpl;
    }

    public function loginUser($userName, $password) {
        $user = new LoginUserUseCase($this->authenticationRepositoryImpl, $this->userRepositoryImpl);
        return $user->loginUser($userName, $password);
    }
}
