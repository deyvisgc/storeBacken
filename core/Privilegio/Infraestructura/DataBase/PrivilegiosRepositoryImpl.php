<?php


namespace Core\Privilegio\Infraestructura\DataBase;


use App\Http\Excepciones\Exepciones;
use Core\Privilegio\Domain\Repositories\PrivilegioRepository;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;

class PrivilegiosRepositoryImpl implements PrivilegioRepository
{


    public function listPrivilegesByRol($idRol)
    {
        try {
           $subPrivilegios = DB::table('rol_has_privilegio as rp')
                ->join('privilegio as p', 'rp.id_privilegio', '=', 'p.id_privilegio')
                ->join('rol as r', 'rp.id_rol', '=', 'r.id_rol')
                ->where('rp.id_rol', $idRol)
                ->select('p.pri_nombre as sub_pri_nombre', 'p.pri_acces', 'p.id_Padre', 'rp.*')
                ->get();
           $privilegiosGrupo= $this->getGrupos();
           $lista = array('subPrivilegios' =>$subPrivilegios, 'privilegiosGrupo'=>$privilegiosGrupo );
           $excepciones = new  Exepciones(true, 'privilegios encontrados', 200, $lista);
          return $excepciones->SendStatus();
        } catch (QueryException $exception) {
            $excepciones = new  Exepciones(false, $exception->getMessage(), $exception->getCode(), []);
          return  $excepciones->SendStatus();
        }
    }

    public function AddPrivilegio(string $nombre, string $acceso, string $icon, int $idPadre, string $grupo)
    {
        try {
            $grupo = $idPadre === 0 ? $nombre : $grupo;
            if ($idPadre === 0) {
                $acceso = $acceso === '' ? '' : '/'.$acceso;
            } else {
                $acceso = '/'.$grupo. '/'. $acceso;
            }
            $idPrivilegio = DB::table('privilegio')->insertGetId([
                'pri_nombre' => $nombre,
                'pri_acces' => $acceso,
                'pri_group' => $grupo,
                'pri_status' => 'active',
                'pri_icon' => $icon,
                'id_Padre' => $idPadre
            ]);
            $typeprivi = $idPadre === 0 ? 'Grupo numero ' : 'Privilegio numero ';
            $message = $typeprivi.$idPrivilegio. ' registrado correctamente';
            $exepciones = new Exepciones(true, $message, 200,[]);
            return $exepciones->SendStatus();
        } catch (QueryException $exception) {
            $exepciones = new Exepciones(false, $exception->getMessage(), $exception->getCode(),[]);
            return $exepciones->SendStatus();
        }
    }

    function getGrupos()
    {
        try {
            $lista = DB::table('privilegio')
                ->select('*')
                ->where('id_Padre', '=' , 0)
                ->get();
            $exepciones = new Exepciones(true, 'grupos Encontrados', 200, $lista);
            return $exepciones->SendStatus();
        } catch (QueryException $exception) {
            $exepciones = new Exepciones(false, $exception->getMessage(), $exception->getCode(), []);
            return $exepciones->SendStatus();
        }
    }

    function getGruposDetalle($id)
    {
        try {
            $lista = DB::table('privilegio')
                ->select('*')
                ->where('id_Padre', '=' , $id)
                ->where('pri_status', '=', 'active' )
                ->get();
            $exepciones = new Exepciones(true, 'Detalle Encontrados', 200, $lista);
            return $exepciones->SendStatus();
        } catch (QueryException $exception) {
            $exepciones = new Exepciones(false, $exception->getMessage(), $exception->getCode(), []);
            return $exepciones->SendStatus();
        }
    }

    function eliminarPrivilegioGrupo($idPadre, $idPrivilegio)
    {
        try {
           $status = DB::table('privilegio')
               ->where('id_Padre', $idPadre)
               ->where('id_privilegio', $idPrivilegio)
               ->delete();
           if ($status === 1) {
               $excepcion = new Exepciones(true, 'Privilegio eliminado correctamente', 200, []);
           } else {
               $excepcion = new Exepciones(false, 'Error al eliminar privilegio', 401, []);

           }
           return $excepcion->SendStatus();
        } catch (QueryException $exception) {
            $excepcion = new Exepciones(false, $exception->getMessage(), $exception->getCode(), []);
            return $excepcion->SendStatus();
        }
    }

    function updatePrivilegio(int $idPrivilegio,string $nombre, string $acceso, string $icon, int $idPadre, string $grupo)
    {
        try {
            if ($idPadre === 0) { // actualizo grupo
                DB::table('privilegio')
                    ->where('id_privilegio', $idPrivilegio)
                    ->update([
                        'pri_nombre' => $nombre,
                        'pri_acces' => '/'.$acceso,
                        'pri_icon' => $icon,
                    ]);
                $exepcion = new Exepciones(true, 'Grupo Actualziado correctamente', 200, []);
            } else { //actualizar privilegios
                DB::table('privilegio')
                    ->where('id_privilegio', $idPrivilegio)
                    ->update([
                        'pri_nombre' => $nombre,
                        'pri_acces' => '/'.$acceso,
                        'pri_group' => $grupo,
                        'idPadre' => $idPadre,
                    ]);
                $exepcion = new Exepciones(true, 'Privilegio Actualziado correctamente', 200, []);
            }
            return $exepcion->SendStatus();
        } catch (QueryException $exception) {
            $exepcion = new Exepciones(false,$exception->getMessage(), $exception->getCode(), []);
            return $exepcion->SendStatus();
        }
    }

    function changeStatusGrupo($data)
    {
        try {
            $status = $data['pri_status'];
            $grupo = $data['pri_group'];
            $idPrivilegio = $data['id_privilegio'];
            if ($status === 'active') {
                $status = 'disable';
                $message = 'Grupo '.$grupo. ' Desabilitado correctamente';
            } else {
                $status = 'active';
                $message = 'Grupo '.$grupo. ' Habilitado correctamente';
            }
           DB::table('privilegio')->where('id_privilegio', $idPrivilegio)
                ->update(['pri_status'=>$status]);
            $excepcion = new Exepciones(true, $message, 200, []);
            return $excepcion->SendStatus();
        } catch (QueryException $exception) {
            $excepcion = new Exepciones(false, $exception->getMessage(), $exception->getCode(), []);
            return $excepcion->SendStatus();
        }
    }

    function getPrivilegios()
    {
        try {
            $lista = DB::table('privilegio')
                ->select('*')
                ->where('id_Padre', '<>' , 0)
                ->get();
            $exepciones = new Exepciones(true, 'privilegios Encontrados', 200, $lista);
            return $exepciones->SendStatus();
        } catch (QueryException $exception) {
            $exepciones = new Exepciones(false, $exception->getMessage(), $exception->getCode(), []);
            return $exepciones->SendStatus();
        }
    }
}
