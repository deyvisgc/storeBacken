<?php


namespace Core\ManagePerson\Infraestructura\DataBase;


use App\Http\Excepciones\Exepciones;
use Core\ManagePerson\Domain\Entity\PersonEntity;
use Core\ManagePerson\Domain\Repositories\PersonRepository;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

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
                $status = DB::table('persona')
                         ->where('id_persona', '=', $personEntity->getIdPersona())
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
            $query = DB::table('persona')
                     ->where('id_persona', $idPerson)
                     ->delete();
            if ($query === 1) {
                $exepcion = new Exepciones(true,'Proveedor Eliminado correctamente',200,[]);
            } else {
                $exepcion = new Exepciones(false,'Error al  Eliminar este proveedor',403,[]);
            }
            return $exepcion->SendStatus();
        } catch (QueryException $exception) {
            $exepcion = new Exepciones(false,$exception->getMessage(),$exception->getCode(),[]);
            return $exepcion->SendStatus();
        }
    }

     function getPersonById(int $idPerson)
    {
        try {
            $lista = DB::table('persona')
                        ->where('id_persona', '=', $idPerson)
                        ->get();
            $exepcion = new Exepciones(true, 'Lista encontrada', 200, $lista[0]);
            return $exepcion->SendStatus();
        } catch (QueryException $exception) {
            $exepcion = new Exepciones(false, 'Lista no encontrada', 403, []);
            return $exepcion->SendStatus();
        }
    }

     function changeStatusPerson($person)
    {
        try {
            $status = $person['per_status'] === 'active' ? 'disabled' : 'active';
            $query = DB::table('persona as per')
                     ->where('per.id_persona', $person['id_persona'])
                     ->update(['per.per_status'=>$status]);
            if ($query === 1) {
                $excepcion = new Exepciones(true,'Estado Actualizado Correctamente', 200, []);
            } else {
                $excepcion = new Exepciones(false,'Error al Actualizar estado', 403, []);
            }
            return $excepcion->SendStatus();
        } catch (QueryException $exception) {
            $excepcion = new Exepciones(false,$exception->getMessage(), $exception->getCode(), []);
            return $excepcion->SendStatus();
        }
    }

    function getPerson($request)
    {
        try {
            $numeroRecnum = $request['numeroRecnum'];
            $cantidadRegistros = $request['cantidadRegistros'];
            $searchText = $request['text'];
            $typePersona = $request['typePersona'];
            $person = DB::table('persona');
            if ($searchText) {
                $person->where('per_numero_documento', 'like', '%'.$searchText.'%');
                $person->orWhere('per_razon_social','like', '%'.$searchText.'%');
            }
            $person->where('per_tipo', '=', $typePersona)
                   ->where('per_status', '=', 'active')
                   ->skip($numeroRecnum)
                   ->take($cantidadRegistros)
                   ->orderBy('id_persona', 'desc')
                   ->get();
            $lista = $person->get();
            if (count($lista) < $cantidadRegistros) {
                $numberRecnum = 0;
                $noMore = true;
            } else {
                $numberRecnum = (int)$numeroRecnum + count($lista);
                $noMore = false;
            }
            $excepcion = new Exepciones(true,'Informacion encontrada', 200, ['lista'=>$lista, 'numeroRecnum'=>$numberRecnum, 'noMore'=>$noMore, 'cantidad'=> count($lista)]
            );
            return $excepcion->SendStatus();
        } catch (QueryException $exception) {
            $excepcion = new Exepciones(false,$exception->getMessage(),$exception->getCode(),[]);
            return $excepcion->SendStatus();
        }
    }
}
