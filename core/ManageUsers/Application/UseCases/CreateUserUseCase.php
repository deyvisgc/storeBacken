<?php


namespace Core\ManageUsers\Application\UseCases;


use Core\ManagePerson\Domain\Entity\PersonEntity;
use Core\ManageUsers\Domain\Entity\UserEntity;
use Core\ManageUsers\Domain\Repositories\UserRepository;

class CreateUserUseCase
{
    /**
     * @var UserRepository
     */
    private UserRepository $userRepository;

    public function __construct(UserRepository $userRepository)
    {
        $this->userRepository = $userRepository;
    }

    public function createUser(UserEntity $userEntity, PersonEntity $personEntity) {
        $responseDB = $this->userRepository->createUser($userEntity, $personEntity);
        if ($responseDB === true) {
            return response()->json(['status' => true, 'code' => 200, 'message' => 'Usuario registrado']);
        } else {
            return response()->json(['status' => false, 'code' => 400, 'message' => 'Usuario no registrado']);
        }
    }
}
