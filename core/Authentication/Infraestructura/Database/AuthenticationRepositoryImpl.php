<?php


namespace Core\Authentication\Infraestructura\Database;


use App\Http\Excepciones\Exepciones;
use Core\Authentication\Domain\Repositories\AuthenticationRepository;
use Core\Traits\EncryptTrait;
use Core\Traits\QueryTraits;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
define('KEY_PASSWORD_TO_DECRYPT','K56QSxGeKImwBRmiY');
class AuthenticationRepositoryImpl implements AuthenticationRepository
{
 use QueryTraits;
 use EncryptTrait;
    public function loginUser($user, $password)
    {
        try {
            $decodePassword = $this->CryptoJSAesDecrypt(KEY_PASSWORD_TO_DECRYPT, $password);
            $users = DB::table('users')->where('us_usuario', $user)
                     ->where('us_status', '=', 'active')->first();
            if ($users != null) {
                if (Hash::check($decodePassword, $users->us_passwor)) {
                    $apikey = base64_encode(str_random(40));
                    DB::table('users')->where('us_usuario', $user)->update(['us_token' => $apikey]);
                    $informacionPersonal = $this->ObtenerInformacionPersonal($users->id_persona, $users->id_rol);
                    $caja = DB::table('caja')->where('id_user', $users->id_user)->first();
                    $rol = DB::table('rol')->where('id_rol', $users->id_rol)->first();
                    $nameRolEncrypt = $this->CryptoJSAesEncrypt(KEY_PASSWORD_TO_DECRYPT, $rol->rol_name);
                   return array(
                       'status' => true,
                       'caja'=>$caja,
                       'perfil' => $informacionPersonal[0],
                       'rolName'=>$nameRolEncrypt,
                       'api_key' =>$apikey
                   );
                } else {
                    $excepciones = new Exepciones(false, 'Credenciales Incorrectas', 401,[]);
                    return $excepciones->SendStatus();
                }
            } else {
                $message = 'El usuario '.$user. ' no existe en nuestra base de datos';
                $excepciones = new Exepciones(false, $message, 401,[]);
                return $excepciones->SendStatus();
            }
        } catch (QueryException $exception) {
            $excepciones = new Exepciones(false, $exception->getMessage(), $exception->getCode(),[]);
            return $excepciones->SendStatus();
        }
    }

    public function logoutUser($oldTokenUser, $idUsuario, $newTokenUser)
    {
        try {
            $query = DB::table('users')
                ->where('id_user', '=', $idUsuario)
                ->where('us_token', '=', $oldTokenUser)
                ->update([
                    'us_token' => $newTokenUser
                ]);
            if ($query === 1) {
                $excepcion = new Exepciones(true,'Session Cerrada Correctamente', 200,[]);
            } else {
                $excepcion = new Exepciones(false,'Error al Cerrar Session', 403,[]);
            }
            return $excepcion->SendStatus();
        } catch (QueryException $exception) {
            $excepcion = new Exepciones(false,$exception->getMessage(), $exception->getCode(),[]);
            return $excepcion->SendStatus();
        }
    }
}
