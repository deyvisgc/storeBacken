<?php


namespace Core\Authentication\Application\UseCase;

define('KEY_PASSWORD_TO_DECRYPT','K56QSxGeKImwBRmiYoP');

use Core\Authentication\Domain\Repositories\AuthenticationRepository;
use Core\ManageUsers\Domain\Repositories\UserRepository;
use Core\Rol\Domain\Repositories\RolRepository;
use Core\Traits\EncryptTrait;
use Illuminate\Support\Facades\Hash;

class LoginUserUseCase
{
    use EncryptTrait;

    /**
     * @var AuthenticationRepository
     */
    private AuthenticationRepository $authenticationRepository;
    /**
     * @var UserRepository
     */
    private UserRepository $userRepository;
    /**
     * @var RolRepository
     */
    private RolRepository $rolRepository;

    public function __construct(
        AuthenticationRepository $authenticationRepository,
        UserRepository $userRepository,
        RolRepository $rolRepository
    )
    {

        $this->authenticationRepository = $authenticationRepository;
        $this->userRepository = $userRepository;
        $this->rolRepository = $rolRepository;
    }

    public function loginUser($userName, $userPassword): \Illuminate\Http\JsonResponse
    {
        $decodePassword = $this->CryptoJSAesDecrypt(KEY_PASSWORD_TO_DECRYPT, $userPassword);

        $user = $this->authenticationRepository->loginUser($userName, $decodePassword);

        if ($user != null) {
            if (Hash::check($decodePassword, $user->us_passwor)) {
                $idRol = $this->CryptoJSAesEncrypt(KEY_PASSWORD_TO_DECRYPT, $user->id_rol);
                $idPersona = $this->CryptoJSAesEncrypt(KEY_PASSWORD_TO_DECRYPT, $user->id_persona);
                $tokenUser = base64_encode(str_random(50));
                $this->userRepository->updateTokenUser($user->id_user, $tokenUser);
                $rolName = $this->rolRepository->listRolById($user->id_rol);

                return response()->json([
                    'status' => true,
                    'token_user' => $tokenUser,
                    'rol' => $idRol,
                    'identifier' => $idPersona,
                    'user_name' => $user->us_name,
                    'name_rol' => $rolName[0]->rol_name,
                ]);

            } else {
                return response()->json(['status' => false, 'message' => 'Error Contraseña'], 500);
            }
        } else {
            return response()->json(['status' => false, 'message' => 'No existe el usuario en el sistema'], 401);
        }
    }
}
