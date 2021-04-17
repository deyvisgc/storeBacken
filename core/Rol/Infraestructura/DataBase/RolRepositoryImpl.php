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
        try {
            return $edit = DB::table('rol')
                ->where('id_rol',$rolEntity->getIdRol())
                ->update([
                    'rol_name' => $rolEntity->getRolName(),
                    'rol_status' => $rolEntity->getRolStatus()
                ]);
        } catch (QueryException $exception) {
            return $exception->getMessage();
        }
    }

    public function createRol(RolEntity $rolEntity)
    {
        try {
            $create = DB::table('rol')->insert([
                'rol_name' => $rolEntity->getRolName(),
                'rol_status' => 'ACTIVE'
            ]);
            if ($create === true) {
                return response()->json(['status' => true, 'code' => 200, 'message' => 'Rol creado']);
            } else {
                return response()->json(['status' => false, 'code' => 400, 'message' => 'Rol no creado']);
            }
        } catch (QueryException $exception) {
            return $exception->getMessage();
        }
    }

    public function deleteRol(int $idRol)
    {
        try {
            return DB::table('rol')
                ->where('id_rol', '=', $idRol)
                ->update([
                    'rol_status' => 'DISABLED',
                ]);
        } catch (QueryException $exception) {
            return $exception->getMessage();
        }
    }

    public function listRolById(int $idRol)
    {
        try {
            return DB::table('rol')
                ->where('id_rol', '=', $idRol)
                ->get();
        } catch (QueryException $exception) {
            return $exception->getMessage();
        }
    }

    public function changeStatusRol(int $idRol)
    {
        try {
            return DB::table('rol')
                ->where('id_rol', '=', $idRol)
                ->update([
                    'rol_status' => 'ACTIVE',
                ]);
        } catch (QueryException $exception) {
            return $exception->getMessage();
        }
    }
}
