<?php


namespace Core\Authentication\Application\UseCase;



use Core\Authentication\Domain\Repositories\AuthenticationRepository;
use Core\ManageUsers\Domain\Repositories\UserRepository;
use Core\Rol\Domain\Repositories\RolRepository;
use Core\Traits\EncryptTrait;
use Illuminate\Support\Facades\Hash;

class LoginUserUseCase
{
    use EncryptTrait;

    /**
     * @var AuthenticationRepository
     */
    private AuthenticationRepository $authenticationRepository;

    public function __construct(AuthenticationRepository $authenticationRepository)
    {
        $this->authenticationRepository = $authenticationRepository;
    }

    public function loginUser($userName, $userPassword)
    {
        return $this->authenticationRepository->loginUser($userName, $userPassword);
    }
}
