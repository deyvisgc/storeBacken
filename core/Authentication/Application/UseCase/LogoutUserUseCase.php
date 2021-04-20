<?php


namespace Core\Authentication\Application\UseCase;
use Core\Authentication\Domain\Repositories\AuthenticationRepository;
use Core\ManageUsers\Domain\Repositories\UserRepository;
use Core\Traits\EncryptTrait;

class LogoutUserUseCase
{
    use EncryptTrait;
    /**
     * @var AuthenticationRepository
     */
    private AuthenticationRepository $authenticationRepository;
    /**
     * @var UserRepository
     */
    private UserRepository $userRepository;

    public function __construct(
        AuthenticationRepository $authenticationRepository,
        UserRepository $userRepository
    )
    {
        $this->authenticationRepository = $authenticationRepository;
        $this->userRepository = $userRepository;
    }

    public function logoutUser($tokenUser, $idUsuario)
    {
        $tokenUserUpdated = base64_encode(str_random(50));
        return $this->authenticationRepository->logoutUser($tokenUser, $idUsuario, $tokenUserUpdated);
    }
}
