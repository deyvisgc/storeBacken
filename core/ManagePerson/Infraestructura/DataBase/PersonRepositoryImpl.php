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
                ->insert($personEntity->toArray());
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
            return DB::table('persona')
                ->where('id_persona', '=', $idPerson)
                ->delete();
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
}
