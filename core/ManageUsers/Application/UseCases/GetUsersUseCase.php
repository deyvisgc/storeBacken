<?php


namespace Core\ManageUsers\Application\UseCases;


use Core\ManageUsers\Domain\Repositories\UserRepository;

class GetUsersUseCase
{
    /**
     * @var UserRepository
     */
    private UserRepository $userRepository;

    public function __construct(UserRepository $userRepository)
    {
        $this->userRepository = $userRepository;
    }

    public function getUsers() {
        return $this->userRepository->listUsers();
    }
}
