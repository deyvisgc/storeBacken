<?php


namespace Core\Privilegio\Domain\Repositories;


interface PrivilegioRepository
{
    public function listPrivileges();
    public function listPrivilegesByRol($idRol);
    public function listPrivilegesByUser($idUser);
    public function listDisabledPrivileges();
}
