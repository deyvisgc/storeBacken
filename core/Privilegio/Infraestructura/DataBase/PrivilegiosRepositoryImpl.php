<?php


namespace Core\Privilegio\Infraestructura\DataBase;


use App\Http\Excepciones\Exepciones;
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
           $roles = DB::table('rol_has_privilegio as rp')
                ->join('privilegio as p', 'rp.id_privilegio', '=', 'p.id_privilegio')
                ->where('id_rol', $idRol)
                ->select('p.*', 'rp.*')
                ->get();
          $excepciones = new  Exepciones(true, 'privilegios encontrados', 200, $roles);
          return $excepciones->SendStatus();
        } catch (QueryException $exception) {
            $excepciones = new  Exepciones(false, $exception->getMessage(), $exception->getCode(), []);
          return  $excepciones->SendStatus();
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
