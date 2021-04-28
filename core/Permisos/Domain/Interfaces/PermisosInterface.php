<?php


namespace Core\Permisos\Domain\Interfaces;


interface PermisosInterface
{
     function Create($idRoldata, $idPrivilegio);
     function Update($data);
     function Delete($idPrivilegio_has_rol);
     function List();
}
