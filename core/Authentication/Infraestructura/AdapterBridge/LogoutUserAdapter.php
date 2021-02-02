<?php


namespace Core\Authentication\Infraestructura\AdapterBridge;


use Core\Authentication\Application\UseCase\LogoutUserUseCase;
use Core\Authentication\Infraestructura\Database\AuthenticationRepositoryImpl;
use Core\ManageUsers\Infraestructura\DataBase\UserRepositoryImpl;

class LogoutUserAdapter
{
    /**
     * @var AuthenticationRepositoryImpl
     */
    private AuthenticationRepositoryImpl $authenticationRepositoryImpl;
    /**
     * @var UserRepositoryImpl
     */
    private UserRepositoryImpl $userRepositoryImpl;

    public function __construct(
        AuthenticationRepositoryImpl $authenticationRepositoryImpl,
        UserRepositoryImpl $userRepositoryImpl
    )
    {
        $this->authenticationRepositoryImpl = $authenticationRepositoryImpl;
        $this->userRepositoryImpl = $userRepositoryImpl;
    }

    public function logoutUser($tokenUser, $idUser) {
        $logout = new LogoutUserUseCase($this->authenticationRepositoryImpl, $this->userRepositoryImpl);

        return $logout->logoutUser($tokenUser, $idUser);
    }
}
