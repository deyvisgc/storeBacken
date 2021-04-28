<?php


namespace Core\Permisos\Aplication\UseCase;


use Core\Permisos\Domain\Interfaces\PermisosInterface;

class CreateUseCasePermisos
{
    public function __construct(PermisosInterface $permisos)
    {
        $this->permisos = $permisos;
    }
    public function AddPrivilegios($idRoldata, $idPrivilegio) {
        return $this->permisos->Create($idRoldata, $idPrivilegio);
    }
}
