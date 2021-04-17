<?php


namespace Core\ManagePerson\Infraestructura\DataBase;


use Core\ManagePerson\Domain\Entity\PersonEntity;
use Core\ManagePerson\Domain\Repositories\PersonRepository;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;

class PersonRepositoryImpl implements PersonRepository
{

    public function createPerson(PersonEntity $personEntity)
    {
        try {
            return DB::table('persona')
                ->insert([
                    'per_nombre' => $personEntity->getPerName(),
                    'per_apellido' => $personEntity->getPerLastName(),
                    'per_direccion' => $personEntity->getPerAddress(),
                    'per_celular' => $personEntity->getPerPhone(),
                    'per_tipo' => $personEntity->getPerType(),
                    'per_tipo_documento' => $personEntity->getPerTypeDocument(),
                    'per_numero_documento' => $personEntity->getPerDocNumber(),
                    'per_status' => 'ACTIVE',
                ]);
        } catch (QueryException $exception) {
            return $exception->getMessage();
        }
    }

    public function updatePerson(PersonEntity $personEntity)
    {
        try {
            return DB::table('persona')
                ->where('id_persona', '=', $personEntity->getIdPersona())
                ->update($personEntity->toArray());
        } catch (QueryException $exception) {
            return $exception->getMessage();
        }
    }

    public function deletePerson(int $idPerson)
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

    public function getPeople()
    {
        try {
            return DB::table('persona')
                ->get();
        } catch (QueryException $exception) {
            return $exception->getMessage();
        }
    }

    public function getPersonById(int $idPerson)
    {
        try {
            return DB::table('persona')
                ->where('id_persona', '=', $idPerson)
                ->get();
        } catch (QueryException $exception) {
            return $exception->getMessage();
        }
    }

    public function changeStatusPerson(int $idPerson)
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
}
