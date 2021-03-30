<?php


namespace Core\Privilegio\Infraestructura\DataBase;


use Core\Privilegio\Domain\Repositories\PrivilegioRepository;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;

class PrivilegiosRepositoryImpl implements PrivilegioRepository
{

    public function listPrivileges()
    {
        try {
            return DB::table('privilegio')->get();
        } catch (QueryException $exception) {
            return $exception->getMessage();
        }
    }

    public function listPrivilegesByRol($idRol)
    {
        try {
            return DB::select('SELECT pri.pri_nombre, pri.pri_acces, pri.pri_group, pri.pri_ico FROM rol as r, privilegio as pri, rol_has_privilegio as rp
                                WHERE pri.id_privilegio = rp.id_privilegio AND r.id_rol = rp.id_rol
                                AND r.id_rol = ?', [$idRol]);
        } catch (QueryException $exception) {
            return $exception->getMessage();
        }
    }

    public function listPrivilegesByUser($idUser)
    {
        // TODO: Implement listPrivilegesByUser() method.
    }

    public function listDisabledPrivileges()
    {
        // TODO: Implement listDisabledPrivileges() method.
    }
}
