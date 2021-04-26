<?php


namespace Core\Rol\Domain\Repositories;


use Core\Rol\Domain\Entity\RolEntity;

interface RolRepository
{
    public function listRol();
    public function editRol(RolEntity $rolEntity);
    public function createRol(RolEntity $rolEntity);
    public function  deleteRol(int $idRol);
    public function changeStatusRol(int $idRol, string $status);
}
