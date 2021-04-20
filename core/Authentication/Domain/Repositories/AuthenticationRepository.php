<?php


namespace Core\Authentication\Domain\Repositories;


interface AuthenticationRepository
{
    public function loginUser($user, $password);
    public function logoutUser($oldTokenUser, $idUsuario, $newTokenUser);
}
