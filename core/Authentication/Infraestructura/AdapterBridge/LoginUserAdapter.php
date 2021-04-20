<?php


namespace Core\Authentication\Infraestructura\AdapterBridge;


use Core\Authentication\Application\UseCase\LoginUserUseCase;
use Core\Authentication\Infraestructura\Database\AuthenticationRepositoryImpl;
use Core\ManageUsers\Infraestructura\DataBase\UserRepositoryImpl;
use Core\Rol\Infraestructura\DataBase\RolRepositoryImpl;

class LoginUserAdapter
{
    /**
     * @var AuthenticationRepositoryImpl
     */
    private AuthenticationRepositoryImpl $authenticationRepositoryImpl;
    /**
     * @var UserRepositoryImpl
     */

    public function __construct( AuthenticationRepositoryImpl $authenticationRepositoryImpl)
    {

        $this->authenticationRepositoryImpl = $authenticationRepositoryImpl;
    }

    public function loginUser($userName, $password) {
        $user = new LoginUserUseCase($this->authenticationRepositoryImpl);
        return $user->loginUser($userName, $password);
    }
}
