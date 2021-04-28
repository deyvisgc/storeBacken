<?php


namespace Core\Permisos\Infraestructure\DataBase;


use App\Http\Excepciones\Exepciones;
use Core\Permisos\Domain\Interfaces\PermisosInterface;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;

class PermisosSql implements PermisosInterface
{

    function Create($idRoldata, $idPrivilegio)
    {
        try {
            foreach ($idPrivilegio as $privi) {
               DB::table('rol_has_privilegio')
                   ->insert([
                       'id_privilegio' => $privi,
                       'id_rol' => $idRoldata
                   ]);
            }
            $exepciones = new Exepciones(true, 'Permisos Creados', 200,[]);
            return $exepciones->SendStatus();
        } catch (QueryException $exception) {
            $exepciones = new Exepciones(false, $exception->getMessage(), $exception->getCode(), []);
            return $exepciones->SendStatus();
        }
    }

    function Update($data)
    {
        // TODO: Implement Update() method.
    }

    function Delete($idPrivilegio_has_rol)
    {
        try {
            $delete = DB::table('rol_has_privilegio')->where('idrol_has_privilegio', '=', $idPrivilegio_has_rol)->delete();
            if ($delete === 1) {
                $excepcion = new Exepciones(true, 'Permiso eliminado', 200, []);
            } else {
                $excepcion = new Exepciones(false, 'Permiso no eliminado', 403, []);
            }
            return $excepcion->SendStatus();
        } catch (QueryException $exception) {
            $excepcion = new Exepciones(false, $exception->getMessage(), $exception->getCode(), []);
            return $excepcion->SendStatus();
        }
    }

    function List()
    {
        try {
            $permisos = DB::table('rol_has_privilegio as rp')
                     ->join('rol as r', 'rp.id_rol', '=', 'r.id_rol')
                     ->join('privilegio as p', 'rp.id_privilegio', '=', 'p.id_privilegio')
                     ->select('rp.*', 'r.rol_name', 'p.pri_nombre')
                     ->get();
            $users = DB::table('users')->where('us_status', '=','active')->get();
            $lista = array('lista'=>$permisos, 'user'=>$users);
            $exepcion = new Exepciones(true, 'Permisos Encontrados', 200, $lista);
            return $exepcion->SendStatus();
        } catch (QueryException $exception) {
            $exepcion = new Exepciones(false, $exception->getMessage(), $exception->getCode(), []);
            return $exepcion->SendStatus();
        }
    }
}
