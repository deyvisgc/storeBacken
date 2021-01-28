<?php


namespace Core\ManageUsers\Domain\Repositories;


use Core\ManagePerson\Domain\Entity\PersonEntity;
use Core\ManageUsers\Domain\Entity\UserEntity;

interface UserRepository
{
    public function createUser(UserEntity $userEntity, PersonEntity $personEntity);
    public function editUser(UserEntity $userEntity);
    public function deleteUser(int $idUser);
    public function listUsers();
    public function getUserById(int $idUser);
    public function updateTokenUser(int $idUser, string $tokenUser);
}
