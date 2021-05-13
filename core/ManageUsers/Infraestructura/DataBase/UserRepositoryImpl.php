<?php


namespace Core\ManageUsers\Infraestructura\DataBase;


use App\Http\Excepciones\Exepciones;
use Core\ManagePerson\Domain\Entity\PersonEntity;
use Core\ManageUsers\Domain\Entity\UserEntity;
use Core\ManageUsers\Domain\Repositories\UserRepository;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class UserRepositoryImpl implements UserRepository
{

    public function createUser(UserEntity $userEntity, PersonEntity $personEntity)
    {
        try {
            DB::beginTransaction();
            $insertPerson = DB::table('persona')
                ->insertGetId([
                    'per_nombre' => $personEntity->getPerName(),
                    'per_apellido' => $personEntity->getPerLastName(),
                    'per_direccion' => $personEntity->getPerAddress(),
                    'per_celular' => $personEntity->getPerPhone(),
                    'per_tipo' => $personEntity->getPerType(),
                    'per_tipo_documento' => $personEntity->getPerTypeDocument(),
                    'per_numero_documento' => $personEntity->getPerDocNumber(),
                    'per_status' => 'active',
                ]);
            $status =  DB::table('users')
                ->insert([
                    'us_usuario' => $userEntity->getUserName(),
                    'us_password' => $userEntity->getUserPassword(),
                    'us_passwor_view' =>$userEntity->getUserPasswordview(),
                    'us_status' => 'active',
                    'us_token' => $userEntity->getUserToken(),
                    'id_persona' => $insertPerson,
                    'id_rol' => $userEntity->getIdRol(),
                ]);
            DB::commit();
            if ($status === true) {
                $excepcion = new Exepciones(true,'Usuario registrado correctamente', 200, []);
            } else {
                $excepcion = new Exepciones(false,'Error al registrar usuario', 401, []);

            }
            return $excepcion->SendStatus();
        } catch (QueryException $exception) {
            DB::rollBack();
            $message = $exception->getMessage();
            $error = explode(" ", $message);
            $duplicate = $error[5].' '. $error[6];
            if ($duplicate === 'Duplicate entry') {
                $message = 'El usuario '.$userEntity->getUserName(). ' ya existe en el sistema';
                $excepcion = new Exepciones(false,$message, $exception->getCode(), []);
            } else {
                $excepcion = new Exepciones(false,$exception->getMessage(), $exception->getCode(), []);
            }
            return $excepcion->SendStatus();
        }
    }

    public function editUser(UserEntity $userEntity, $perfil)
    {
        try {
            $exist = DB::table('users')
                     ->where('us_usuario', $userEntity->getUserName()
                     )->where('id_user',  $userEntity->getIdUser())->exists();
            if ($exist) {
                $excepcion = new Exepciones(false,'El usuario '.$userEntity->getUserName().' ya te pertenece Dijite otro', 402, []);
            } else {
                if ($perfil) {
                    $status = DB::table('users') ->where('id_user', '=', $userEntity->getIdUser())
                        ->update([ 'us_usuario' => $userEntity->getUserName()
                        ]);
                } else {
                    $status = DB::table('users') ->where('id_persona', '=', $userEntity->getIdPersona())
                        ->update([ 'us_usuario' => $userEntity->getUserName(),  'id_rol' => $userEntity->getIdRol()
                        ]);
                }
                if ($status === 1 ) {
                    $excepcion = new Exepciones(true,'Credenciales actualizado correctamente', 200, []);
                } else {
                    $excepcion = new Exepciones(false,'Error al actualizar credenciales', 403, []);
                }
            }
            return $excepcion->SendStatus();
        } catch (QueryException $exception) {
            $message = $exception->getMessage();
            $error = explode(" ", $message);
            $duplicate = $error[5].' '. $error[6];
            if ($duplicate === 'Duplicate entry') {
                $message = 'El usuario '.$userEntity->getUserName(). ' ya existe en el sistema';
                $excepcion = new Exepciones(false,$message, $exception->getCode(), []);
            } else {
                $excepcion = new Exepciones(false,$exception->getMessage(), $exception->getCode(), []);
            }
            return $excepcion->SendStatus();
        }
    }

    public function listUsers()
    {
        try {
            $person = DB::table('users as u')
                ->join('persona as p', 'u.id_persona', '=', 'p.id_persona')
                ->join('rol as r','u.id_rol','=', 'r.id_rol')
                ->select('u.us_usuario','u.id_user', 'p.*', 'r.rol_name')
                ->get();
            $excepcion = new Exepciones(true,'Informacion encontrada',200,$person);
            return $excepcion->SendStatus();
        } catch (QueryException $exception) {
            $excepcion = new Exepciones(false,'Informacion no encontrada',403,[]);
            return $excepcion->SendStatus();
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

    public function getUserByIdPerson(int $idUsers)
    {
        try {
            if ($idUsers <= 0) {
                $exepciones = new Exepciones(false, 'Usuario no encontrado', 403, []);
                return $exepciones->SendStatus();
            }
            $person = DB::table('users as u')
                     ->join('persona as p', 'u.id_persona', '=', 'p.id_persona')
                     ->where('id_user', '=', $idUsers)
                     ->select('u.*', 'p.*')
                     ->get();
            if ($person->count() > 0) {
                $exepciones = new Exepciones(true, 'Informacion Encontrada', 200, ['person'=>$person[0]]);
            } else {
                $exepciones = new Exepciones(false, 'Informacion no Encontrada', 403, ['person'=>[]]);
            }
            return $exepciones->SendStatus();
        } catch (QueryException $exception) {
            $exepciones = new Exepciones(false, $exception->getMessage(), $exception->getCode(), []);
            return $exepciones->SendStatus();
        }
    }

    function updatePassword($passwordActual,$passwordNueva,$us_usuario, $passwordView)
    {
        try {
            $users = DB::table('users')->where('us_usuario', $us_usuario)->where('us_status', '=', 'active')->first();
            if ($users != null) {
                if (Hash::check($passwordActual, $users->us_password)) {
                    DB::table('users')->where('us_usuario', $us_usuario)->update(
                        [
                            'us_password' => Hash::make($passwordNueva),
                            'us_passwor_view' => $passwordView
                        ]);
                    $message = 'La contrseña '.$passwordActual. ' actualizada correctamente';
                    $excepciones = new Exepciones(1, $message, 200,[]);
                    return $excepciones->SendStatus();
                } else {
                    $message = 'La contraseña '.$passwordActual. ' no existe';
                    $excepciones = new Exepciones(2, $message, 401,[]);
                    return $excepciones->SendStatus();
                }

            } else {
                $message = 'El usuario '.$us_usuario. ' no existe en nuestra base de datos';
                $excepciones = new Exepciones(3, $message, 401,[]);
                return $excepciones->SendStatus();
            }
        } catch (QueryException $exception) {
            $excepciones = new Exepciones(3, $exception->getMessage(), $exception->getCode(),[]);
            return $excepciones->SendStatus();
        }
    }

    function ChangeUsuario($data)
    {
        try {
            $idUsers = $data['idUsuario'];
            $usuario = $data['usuario'];
            if ($idUsers === 0) {
                $excepcion = new Exepciones(3,'Usuario no existe',403, []);
                return $excepcion->SendStatus();
            }
            $users = DB::table('users')->where('us_usuario', $usuario)->where('us_status', '=', 'active')->exists();
            if ($users) {
                $message = 'El usuario '.$usuario. ' ya existe en el sistema';
                $excepcion = new Exepciones(1,$message,403, []);
                return $excepcion->SendStatus();
            } else {
                DB::table('users')->where('id_user', $idUsers)->update(['us_usuario'=>$usuario]);
                $excepcion = new Exepciones(2,'Usuario actualizado correctamente',200, []);
                return $excepcion->SendStatus();
            }
        } catch (QueryException $exception) {
            $excepcion = new Exepciones(3,$exception->getMessage(),$exception->getCode(), []);
            return $excepcion->SendStatus();
        }
    }

    function SearchUser(string $params)
    {
        try {
            $search = DB::table('users')
                ->where('us_usuario', 'like', '%'.$params.'%')
                ->where('us_status', '=', 'active')
                ->get();
            $ecepciones = new Exepciones(true, 'Usuario Encontrados', 200, $search);
            return $ecepciones->SendStatus();
        } catch (QueryException $exception) {
            $ecepciones = new Exepciones(false, $exception->getMessage(), $exception->getCode(), []);
            return $ecepciones->SendStatus();
        }
    }

    function RecuperarPassword($idUsuario, $passwordNueva,$passwordView)
    {
        try {
            $search = DB::table('users')->where('id_user', $idUsuario)->update(['us_password'=>$passwordNueva, 'us_passwor_view'=>$passwordView]);
            if ($search === 1) {
                $ecepciones = new Exepciones(true, 'Exito al recuperar contraseña', 200, []);
            } else {
                $ecepciones = new Exepciones(false, 'Error al recuperar contraseña', 403, []);

            }
            return $ecepciones->SendStatus();
        } catch (QueryException $exception) {
            $ecepciones = new Exepciones(false, $exception->getMessage(), $exception->getCode(), []);
            return $ecepciones->SendStatus();
        }
    }
    function deleteUser($data)
    {
        try {
            $caja = DB::table('caja')->where('id_user', $data['id_user'])->first();
            if(isset($caja)) {
                $message = 'El usuario '.$data['us_usuario'].' existe en la caja Nro '.$caja->ca_name.' Elimine esta caja para eliminar este usuario.';
                $exepciones= new Exepciones(false,$message, 403, []);
                return $exepciones->SendStatus();
            } else {
                $sql= "DELETE users,persona FROM users INNER JOIN persona ON users.id_persona = persona.id_persona WHERE users.id_persona = ?";
                $status = DB::delete($sql, [$data['id_persona']]);
                if ($status === 2) {
                    $message = 'El usuario '.$data['us_usuario'].' fue eliminado correctamente.';
                    $exepciones= new Exepciones(true,$message, 200, []);
                } else {
                    $message = 'El usuario '.$data['us_usuario'].' no eliminado';
                    $exepciones= new Exepciones(false,$message, 403, []);
                }
                return $exepciones->SendStatus();
            }
        } catch (QueryException $exception) {
            return $exception->getMessage();
        }
    }
    function ChangeStatus($data)
    {
        try {
            $status = $data['per_status'] === 'active' ? 'disabled' : 'active';
            $query = DB::table('users as us')
                ->join('persona as p', 'us.id_persona', '=', 'p.id_persona')
                ->where('us.id_persona', $data['id_persona'])
                ->update(['us.us_status'=>$status, 'p.per_status'=>$status]);
            if ($query === 2) {
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
}
