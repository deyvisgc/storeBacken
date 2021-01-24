<?php


namespace Core\Privilegio\Domain\Repositories;


interface PrivilegioRepository
{
    public function listPrivileges();
    public function listPrivilegesByRol(int $idRol);
    public function listPrivilegesByUser(int $idUser);
    public function listDisabledPrivileges();
}
