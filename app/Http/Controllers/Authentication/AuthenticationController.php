<?php


namespace App\Http\Controllers\Authentication;


use App\Http\Controllers\Controller;
use Core\Authentication\Infraestructura\AdapterBridge\LoginUserAdapter;
use Core\Traits\EncryptTrait;
use Illuminate\Http\Request;

class AuthenticationController extends Controller
{
    use EncryptTrait;
    /**
     * @var LoginUserAdapter
     */
    private LoginUserAdapter $loginUserAdapter;

    public function __construct(
        LoginUserAdapter $loginUserAdapter
    )
    {
        $this->loginUserAdapter = $loginUserAdapter;
    }

    public function loginUser(Request $request): \Illuminate\Http\JsonResponse
    {
        $userName = $request['userName'];
        $userPassword = $request['userPassword'];

        return response()->json($this->loginUserAdapter->loginUser($userName, $userPassword));
    }
}
