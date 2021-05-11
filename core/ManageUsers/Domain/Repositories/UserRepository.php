<?php


namespace Core\ManageUsers\Domain\Repositories;


use Core\ManagePerson\Domain\Entity\PersonEntity;
use Core\ManageUsers\Domain\Entity\UserEntity;

interface UserRepository
{
    public function createUser(UserEntity $userEntity, PersonEntity $personEntity);
    public function editUser(UserEntity $userEntity);
    public function deleteUser($data);
    public function listUsers();
    public function getUserById(int $idUser);
    public function updateTokenUser(int $idUser, string $tokenUser);
    public function getUserByIdPerson(int $idUsers);
    function updatePassword($passwordActual,$passwordNueva,$us_usuario, $passwordView);
    function ChangeUsuario($usuario);
    function RecuperarPassword($idUsuario, $passwordNueva,$passwordView);
    function SearchUser(string $params);
    function ChangeStatus($data);
}
