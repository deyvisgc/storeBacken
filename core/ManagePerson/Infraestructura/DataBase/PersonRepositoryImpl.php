<?php


namespace Core\ManagePerson\Infraestructura\DataBase;


use App\Http\Excepciones\Exepciones;
use Core\ManagePerson\Domain\Entity\PersonEntity;
use Core\ManagePerson\Domain\Repositories\PersonRepository;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;

class PersonRepositoryImpl implements PersonRepository
{

     function createPerson($razonSocial,$tipoDocumento,$numerDocumento,$telefono,$direccion,$typePerson)
    {
        try {
            $status = DB::table('persona')
                ->insert([
                    'per_razon_social' => $razonSocial,
                    'per_tipo_documento' => $tipoDocumento,
                    'per_numero_documento' => $numerDocumento,
                    'per_celular' => $telefono,
                    'per_tipo' => $typePerson,
                    'per_status' => 'active',
                    'per_direccion' =>$direccion
                ]);
            if ($status) {
                $exepciones = new Exepciones(true,'Proveedor registrado correctamente',200,[]);
            } else {
                $exepciones = new Exepciones(false,'Error al  este Proveedor',403,[]);
            }
            return $exepciones->SendStatus();
        } catch (QueryException $exception) {
            $exepciones = new Exepciones(false,$exception->getMessage(),$exception->getCode(),[]);
            return $exepciones->SendStatus();
        }
    }

     function updatePerson(PersonEntity $personEntity, $perfil)
    {
        try {
            if ($perfil) {
                $status = DB::table('persona')
                       ->where('id_persona', '=', $personEntity->getIdPersona())
                       ->update($personEntity->toArrayPerfil());
                if ($status === 1) {
                    $message = 'Actualizado correctamente';
                    $excepcion = new Exepciones(true, $message,200, []);
                } else {
                    $message = 'Error al Actualizar';
                    $excepcion = new Exepciones(false, $message,403, []);
                }
                return $excepcion->SendStatus();
            } else {
                $status = DB::table('persona')->
                       where('id_persona', '=', $personEntity->getIdPersona())
                       ->update($personEntity->toArray());
                if ($status === 1) {
                    $message = 'Actualizado correctamente';
                    $excepcion = new Exepciones(true, $message,200, []);
                } else {
                    $message = 'Error al Actualizar';
                    $excepcion = new Exepciones(false, $message,403, []);
                }
                return $excepcion->SendStatus();
            }
        } catch (QueryException $exception) {
            $excepcion = new Exepciones(false, $exception->getMessage(),$exception->getCode(), []);
            return $excepcion->SendStatus();
        }
    }

     function deletePerson(int $idPerson)
    {
        try {
            $exist = DB::table('user')
                ->where('id_persona', '=', $idPerson)
                ->exists();
            if ($exist == true) {
                DB::table('user')
                    ->where('id_persona', '=', $idPerson)
                    ->update([
                        'us_status' => 'DISABLED',
                    ]);
            }

            return DB::table('persona')
                ->where('id_persona', '=', $idPerson)
                ->update([
                    'per_status' => 'DISABLED'
                ]);
        } catch (QueryException $exception) {
            return $exception->getMessage();
        }
    }

     function getPersonById(int $idPerson)
    {
        try {
            return DB::table('persona')
                ->where('id_persona', '=', $idPerson)
                ->get();
        } catch (QueryException $exception) {
            return $exception->getMessage();
        }
    }

     function changeStatusPerson(int $idPerson)
    {
        try {
            $exist = DB::table('user')
                ->where('id_persona', '=', $idPerson)
                ->exists();

            if ($exist == true) {
                DB::table('user')
                    ->where('id_persona', '=', $idPerson)
                    ->update([
                        'us_status' => 'ACTIVE',
                    ]);
            }

            return DB::table('persona')
                ->where('id_persona', '=', $idPerson)
                ->update([
                    'per_status' => 'ACTIVE'
                ]);
        } catch (QueryException $exception) {
            return $exception->getMessage();
        }
    }

    function getPerson()
    {
        try {
            $person = DB::table('persona as p')->get();
            $excepcion = new Exepciones(true,'Informacion encontrada',200,$person);
            return $excepcion->SendStatus();
        } catch (QueryException $exception) {
            $excepcion = new Exepciones(false,'Informacion no encontrada',403,[]);
            return $excepcion->SendStatus();
        }
    }
}
