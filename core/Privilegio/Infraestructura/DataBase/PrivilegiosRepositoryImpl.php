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

    public function listPrivilegesByRol(int $idRol)
    {
        // TODO: Implement listPrivilegesByRol() method.
    }

    public function listPrivilegesByUser(int $idUser)
    {
        // TODO: Implement listPrivilegesByUser() method.
    }

    public function listDisabledPrivileges()
    {
        // TODO: Implement listDisabledPrivileges() method.
    }
}
