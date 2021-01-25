<?php


namespace Core\Rol\Infraestructura\DataBase;


use Core\Rol\Domain\Entity\RolEntity;
use Core\Rol\Domain\Repositories\RolRepository;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;

class RolRepositoryImpl implements RolRepository
{

    public function listRol()
    {
        try {
            return DB::table('rol')->get();
        } catch (QueryException $exception) {
            return $exception->getMessage();
        }
    }

    public function editRol(RolEntity $rolEntity)
    {
        // TODO: Implement editRol() method.
    }

    public function createRol(RolEntity $rolEntity)
    {
        // TODO: Implement createRol() method.
    }

    public function deleteRol(int $idRol)
    {
        // TODO: Implement deleteRol() method.
    }
}
