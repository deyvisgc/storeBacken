<?php


namespace Core\Rol\Infraestructura\DataBase;


use App\Http\Excepciones\Exepciones;
use Core\Rol\Domain\Entity\RolEntity;
use Core\Rol\Domain\Repositories\RolRepository;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;

class RolRepositoryImpl implements RolRepository
{

    public function listRol()
    {
        try {
            $lista = DB::table('rol')->get();
            $exepcion = new Exepciones(true, 'Roles encontrados', 200, $lista);
            return  $exepcion->SendStatus();
        } catch (QueryException $exception) {
            $exepcion = new Exepciones(false, $exception->getMessage(), $exception->getCode(), []);
            return  $exepcion->SendStatus();
        }
    }

    public function editRol(RolEntity $rolEntity)
    {
        try {
             $edit = DB::table('rol')
                     ->where('id_rol',$rolEntity->getIdRol())->update([
                       'rol_name' => $rolEntity->getRolName(),
                     ]);
            if ($edit === 1) {
                $excepcion = new Exepciones(true, 'rol Actualizado', 200, []);
            } else {
                $excepcion = new Exepciones(false, 'rol no Actualizado', 403, []);
            }
            return  $excepcion->SendStatus();
        } catch (QueryException $exception) {
            $excepcion = new Exepciones(false, $exception->getMessage(),$exception->getCode(), []);
            return $excepcion->SendStatus();
        }
    }

    public function createRol(RolEntity $rolEntity)
    {
        try {
            $create = DB::table('rol')->insert([
                'rol_name' => $rolEntity->getRolName(),
                'rol_status' => 'active'
            ]);
            if ($create === true) {
                $excepcion = new Exepciones(true, 'Rol creado Correctamente', 200,[]);
            } else {
                $excepcion = new Exepciones(false, 'Error al crear roles', 403,[]);
            }
            return  $excepcion->SendStatus();
        } catch (QueryException $exception) {
            $excepcion = new Exepciones(false, $exception->getMessage(), $exception->getCode(),[]);
            return  $excepcion->SendStatus();
        }
    }

    public function deleteRol(int $idRol)
    {
        try {
            $delete = DB::table('rol')->where('id_rol', '=', $idRol)->delete();
            if ($delete === 1) {
                $excepcion = new Exepciones(true, 'Rol eliminado', 200, []);
            } else {
                $excepcion = new Exepciones(false, 'Rol no eliminado', 403, []);
            }
            return $excepcion->SendStatus();
        } catch (QueryException $exception) {
            $excepcion = new Exepciones(false, $exception->getMessage(), $exception->getCode(), []);
            return $excepcion->SendStatus();
        }
    }
    public function changeStatusRol(int $idRol, string $status)
    {
        try {
            if ($status === 'active') {
                $status = 'disable';
                $message = 'Rol Desabilitado';
                $messageError = 'Rol no Desabilitado';
            } else {
                $status = 'active';
                $message = 'Rol Habilitado';
                $messageError = 'Rol no Habilitado';
            }
            $rol = DB::table('rol')->where('id_rol', '=', $idRol)
                   ->update([
                      'rol_status' => $status,
                   ]);

            if ($rol === 1) {
                $exepcion = new Exepciones(true, $message, 200, []);
            } else {
                $exepcion = new Exepciones(false, $messageError, 403, []);
            }
            return $exepcion->SendStatus();
        } catch (QueryException $exception) {
            $exepcion = new Exepciones(false, $exception->getMessage(), $exception->getCode(), []);
            return $exepcion->SendStatus();
        }
    }
}
