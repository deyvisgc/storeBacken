<?php


namespace Core\Permisos\Aplication\UseCase;


use Core\Permisos\Domain\Interfaces\PermisosInterface;

class DeleteUseCasePermisos
{
    public function __construct(PermisosInterface $permisos)
    {
        $this->permisos = $permisos;
    }
    function delete($idPermisos) {
        return $this->permisos->Delete($idPermisos);
    }
}
