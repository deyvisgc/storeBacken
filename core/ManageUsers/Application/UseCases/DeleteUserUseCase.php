<?php


namespace Core\ManageUsers\Application\UseCases;


use Core\ManageUsers\Domain\Repositories\UserRepository;

class DeleteUserUseCase
{
    /**
     * @var UserRepository
     */
    private UserRepository $userRepository;

    public function __construct(UserRepository $userRepository)
    {
        $this->userRepository = $userRepository;
    }

    public function deleteUser($data) {
        return $this->userRepository->deleteUser($data);
    }
}
