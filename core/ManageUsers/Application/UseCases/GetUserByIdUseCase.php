<?php


namespace Core\ManageUsers\Application\UseCases;


use Core\ManageUsers\Domain\Repositories\UserRepository;

class GetUserByIdUseCase
{
    /**
     * @var UserRepository
     */
    private UserRepository $userRepository;

    public function __construct(UserRepository $userRepository)
    {
        $this->userRepository = $userRepository;
    }

    public function getUserById(int $idUser) {
        return $this->userRepository->getUserById($idUser);
    }
}
