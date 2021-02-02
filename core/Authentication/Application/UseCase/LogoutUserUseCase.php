<?php


namespace Core\Authentication\Application\UseCase;

define('KEY_PASSWORD_TO_DECRYPT','K56QSxGeKImwBRmiYoP');
use Core\Authentication\Domain\Repositories\AuthenticationRepository;
use Core\ManageUsers\Domain\Repositories\UserRepository;
use Core\Traits\EncryptTrait;

class LogoutUserUseCase
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

    public function __construct(
        AuthenticationRepository $authenticationRepository,
        UserRepository $userRepository
    )
    {
        $this->authenticationRepository = $authenticationRepository;
        $this->userRepository = $userRepository;
    }

    public function logoutUser($tokenUser, $idPersona): \Illuminate\Http\JsonResponse
    {
        $tokenUserUpdated = base64_encode(str_random(50));
        $idPersona = $this->CryptoJSAesDecrypt(KEY_PASSWORD_TO_DECRYPT, $idPersona);

        $updated = $this->authenticationRepository->logoutUser($tokenUser, $idPersona, $tokenUserUpdated);

        if ($updated === 1) {
            return response()->json(['status' => true, 'code' => 200, 'message' => 'Sesion caducada']);
        } else {
            return response()->json(['status' => false, 'code' => 400, 'message' => 'No se puede cerrar sesion']);
        }
    }
}
