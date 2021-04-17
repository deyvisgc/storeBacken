<?php


namespace Core\ManageUsers\Infraestructura\DataBase;


use Core\ManagePerson\Domain\Entity\PersonEntity;
use Core\ManageUsers\Domain\Entity\UserEntity;
use Core\ManageUsers\Domain\Repositories\UserRepository;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;

class UserRepositoryImpl implements UserRepository
{

    public function createUser(UserEntity $userEntity, PersonEntity $personEntity)
    {
        try {
            $insertPerson = DB::table('persona')
                ->insertGetId([
                    'per_nombre' => $personEntity->getPerName(),
                    'per_apellido' => $personEntity->getPerLastName(),
                    'per_direccion' => $personEntity->getPerAddress(),
                    'per_celular' => $personEntity->getPerPhone(),
                    'per_tipo' => $personEntity->getPerType(),
                    'per_tipo_documento' => $personEntity->getPerTypeDocument(),
                    'per_numero_documento' => $personEntity->getPerDocNumber(),
                    'per_status' => 'ACTIVE',
                ]);

            return DB::table('user')
                ->insert([
                    'us_name' => $userEntity->getUserName(),
                    'us_passwor' => $userEntity->getUserPassword(),
                    'us_status' => $userEntity->getUserStatus(),
                    'us_token' => $userEntity->getUserToken(),
                    'id_persona' => $insertPerson,
                    'id_rol' => $userEntity->getIdRol(),
                ]);
        } catch (QueryException $exception) {
            return $exception->getMessage();
        }
    }

    public function editUser(UserEntity $userEntity)
    {
        try {
            return DB::table('user')
                ->where('id_user', '=', $userEntity->getIdUser())
                ->update([
                    'us_name' => $userEntity->getUserName(),
                    'us_status' => $userEntity->getUserStatus(),
                    'id_rol' => $userEntity->getIdRol(),
                ]);
        } catch (QueryException $exception) {
            return $exception->getMessage();
        }
    }

    public function deleteUser(int $idUser)
    {
        try {
            return DB::table('user')
                ->where('id_user', '=', $idUser)
                ->update([
                    'us_status' => 'DISABLED'
                ]);
        } catch (QueryException $exception) {
            return $exception->getMessage();
        }
    }

    public function listUsers()
    {
        try {
            return DB::table('user')
                ->where('us_status', '=', 'ACTIVE')
                ->get();
        } catch (QueryException $exception) {
            return $exception->getMessage();
        }
    }

    public function getUserById(int $idUser)
    {
        try {
            return DB::table('user')
                ->where('id_user','=', $idUser)
                ->get();
        } catch (QueryException $exception) {
            return $exception->getMessage();
        }
    }

    public function updateTokenUser(int $idUser, string $tokenUser)
    {
        try {
            return DB::table('user')
                ->where('id_user', '=', $idUser)
                ->update([
                    'us_token' => $tokenUser
                ]);
        } catch (QueryException $exception) {
            return $exception->getMessage();
        }
    }

    public function getUserByIdPerson(int $idPerson)
    {
        try {
            return DB::table('user')
                ->where('id_persona', '=', $idPerson)
                ->get();
        } catch (QueryException $exception) {
            return $exception->getMessage();
        }
    }
}
