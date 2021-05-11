<?php


namespace App\Http\Controllers\Authentication;


use App\Http\Controllers\Controller;
use Core\Authentication\Infraestructura\AdapterBridge\LoginUserAdapter;
use Core\Authentication\Infraestructura\AdapterBridge\LogoutUserAdapter;
use Core\Traits\EncryptTrait;
use Illuminate\Http\Request;

class AuthenticationController extends Controller
{
    use EncryptTrait;
    /**
     * @var LoginUserAdapter
     */
    private LoginUserAdapter $loginUserAdapter;
    /**
     * @var LogoutUserAdapter
     */
    private LogoutUserAdapter $logoutUserAdapter;

    public function __construct(
        LoginUserAdapter $loginUserAdapter,
        LogoutUserAdapter $logoutUserAdapter
    )
    {
        $this->loginUserAdapter = $loginUserAdapter;
        $this->logoutUserAdapter = $logoutUserAdapter;
        $this->middleware('auth', ['only' => [
           'logoutUser'
        ]]);
    }

    public function loginUser(Request $request)
    {
        $userName = $request->input('userName');
        $userPassword = $request->input('password');

        return response()->json($this->loginUserAdapter->loginUser($userName, $userPassword));
    }

    public function logoutUser(Request $request): \Illuminate\Http\JsonResponse
    {
        $tokenUser = $request['token'];
        $idPersona = $request['idUsuario'];

        return response()->json($this->logoutUserAdapter->logoutUser($tokenUser, $idPersona));
    }
}


