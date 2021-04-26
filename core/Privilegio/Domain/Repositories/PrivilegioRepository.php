<?php


namespace Core\Privilegio\Domain\Repositories;


interface PrivilegioRepository
{
     function listPrivilegesByRol($idRol);
     function getGrupos();
     function getGruposDetalle($id);
     function getPrivilegios();
     function AddPrivilegio(string $nombre, string $acceso, string $icon, int $idPadre, string $grupo);
     function updatePrivilegio(int $idPrivilegio,string $nombre, string $acceso, string $icon, int $idPadre, string $grupo);
     function changeStatusGrupo($data);
     function eliminarPrivilegioGrupo($idPadre, $idPrivilegio);
}
