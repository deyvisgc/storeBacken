<?php


namespace Core\ManageUsers\Application\UseCases;


use Core\ManageUsers\Domain\Repositories\UserRepository;

class GetUserByIdPersonUseCase
{
    /**
     * @var UserRepository
     */
    private UserRepository $userRepository;

    public function __construct(UserRepository $userRepository)
    {
        $this->userRepository = $userRepository;
    }
    function getUserByIdPerson(int $idUsers) {
        return  $this->userRepository->getUserByIdPerson($idUsers);
    }
    function SearchUser(string  $params) {
        return  $this->userRepository->SearchUser($params);

    }
}
