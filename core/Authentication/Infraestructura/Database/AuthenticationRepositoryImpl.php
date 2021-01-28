<?php


namespace Core\Authentication\Infraestructura\Database;


use Core\Authentication\Domain\Repositories\AuthenticationRepository;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;

class AuthenticationRepositoryImpl implements AuthenticationRepository
{

    public function loginUser($user, $password)
    {
        try {
            return DB::table('user')
                ->where('us_name','=', $user)
                ->where('us_status', '=', 'ACTIVE')
                ->first();
        } catch (QueryException $exception) {
            return $exception->getMessage();
        }
    }

    public function logoutUser($tokenUser, $user)
    {
        // TODO: Implement logoutUser() method.
    }
}
