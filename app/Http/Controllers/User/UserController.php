<?php


namespace App\Http\Controllers\User;


use App\Http\Controllers\Controller;
use Core\ManagePerson\Domain\Entity\PersonEntity;
use Core\ManageUsers\Domain\Entity\UserEntity;
use Core\ManageUsers\Infraestructura\AdapterBridge\CreateUserAdapter;
use Core\ManageUsers\Infraestructura\AdapterBridge\DeleteUserAdapter;
use Core\ManageUsers\Infraestructura\AdapterBridge\GetUserByIdAdapter;
use Core\ManageUsers\Infraestructura\AdapterBridge\GetUserByIdPersonAdapter;
use Core\ManageUsers\Infraestructura\AdapterBridge\GetUsersAdapter;
use Core\ManageUsers\Infraestructura\AdapterBridge\UpdateUserAdapter;
use Core\Traits\EncryptTrait;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
define('KEY_PASSWORD_TO_DECRYPT','K56QSxGeKImwBRmiY');
class UserController extends Controller
{
    /**
     * @var CreateUserAdapter
     */
    private CreateUserAdapter $createUserAdapter;
    /**
     * @var DeleteUserAdapter
     */
    private DeleteUserAdapter $deleteUserAdapter;
    /**
     * @var UpdateUserAdapter
     */
    private UpdateUserAdapter $updateUserAdapter;
    /**
     * @var GetUsersAdapter
     */
    private GetUsersAdapter $getUsersAdapter;
    /**
     * @var GetUserByIdAdapter
     */
    private GetUserByIdAdapter $getUserByIdAdapter;
    /**
     * @var GetUserByIdPersonAdapter
     */
    private GetUserByIdPersonAdapter $getUserByIdPersonAdapter;
    use EncryptTrait;
    public function __construct(
        CreateUserAdapter $createUserAdapter,
        DeleteUserAdapter $deleteUserAdapter,
        UpdateUserAdapter $updateUserAdapter,
        GetUsersAdapter $getUsersAdapter,
        GetUserByIdAdapter $getUserByIdAdapter,
        GetUserByIdPersonAdapter $getUserByIdPersonAdapter
    )
    {
        $this->createUserAdapter = $createUserAdapter;
        $this->deleteUserAdapter = $deleteUserAdapter;
        $this->updateUserAdapter = $updateUserAdapter;
        $this->getUsersAdapter = $getUsersAdapter;
        $this->getUserByIdAdapter = $getUserByIdAdapter;
        $this->getUserByIdPersonAdapter = $getUserByIdPersonAdapter;
        $this->middleware('auth');
    }
    function createUser(Request $request)
    {
        // User Data
        //return response()->json($request['people']['nameUser']);
        $nameUser= $request['people']['nameUser'];
        $password = $request['people']['password'];
        $passwordView = $this->CryptoJSAesEncrypt(KEY_PASSWORD_TO_DECRYPT, $password);
        $idRol = $request['people']['idRol'];
        $token = base64_encode(str_random(50));

        // person data
        $name = $request['people']['name'];
        $lastName = $request['people']['lastName'];
        $address = $request['people']['address'];
        $phone = $request['people']['phone'];
        $typePerson = $request['people']['typePerson'];
        $typeDocument = $request['people']['typeDocument'];
        $docNumber = $request['people']['docNumber'];
        $user = new UserEntity(0, $nameUser,Hash::make($password),'active',$token, 0, $idRol,$passwordView);
        $person = new PersonEntity(0, $name,$lastName,$address,$phone,$typePerson,$typeDocument,$docNumber);
        return response()->json($this->createUserAdapter->createUser($user,$person));
    }
    function getUser()
    {
        return response()->json($this->getUsersAdapter->getUser());
    }
    function getUserById(int $idUser): \Illuminate\Http\JsonResponse
    {
        return response()->json($this->getUserByIdAdapter->getUserById($idUser));
    }
    function updateUser(Request $request): \Illuminate\Http\JsonResponse
    {
        $userName = $request['user']['nameUser'];
        $idRol = $request['user']['idRol'];
        $idPersona = $request['user']['idPersona'];
        $user = new UserEntity(0, $userName, '', '', '', $idPersona, $idRol, '');

        return response()->json($this->updateUserAdapter->updateUser($user));
    }
    function getUserByIdPerson(int $idUsers)
    {
        return response()->json($this->getUserByIdPersonAdapter->getUserByIdPerson($idUsers));
    }
    function UpdateContraseña(Request  $request)
    {
        $passwordActual = $request->passwords['passwordActual'];
        $passwordNueva = $request->passwords['passwordNueva'];
        $us_usuario = $request->passwords['us_usuario'];
        $passwordView = $this->CryptoJSAesEncrypt(KEY_PASSWORD_TO_DECRYPT, $passwordNueva);
        return response()->json($this->updateUserAdapter->ActualizarPassword($passwordActual,$passwordNueva,$us_usuario, $passwordView));
    }
    function ChangeUsuario(Request $request) {
        return response()->json($this->updateUserAdapter->ChangeUsuario($request->usuario));
    }
    function SearchUsuario(Request $request) {
        return response()->json($this->getUserByIdPersonAdapter->SearchUser($request->params));
    }
    function RecuperarPassword(Request $request) {
        $idUsuario = $request->params['idUsuario'];
        $passwordNueva = $request->params['nuevaPassword'];
        $passwordView = $this->CryptoJSAesEncrypt(KEY_PASSWORD_TO_DECRYPT, $passwordNueva);
        return response()->json($this->updateUserAdapter->RecuperarPassword($idUsuario, Hash::make($passwordNueva),$passwordView));
    }
    function DeleteUsersandPerson(Request $request) {
        return response()->json($this->deleteUserAdapter->deleteUser($request->params));
    }
    function ChangeStatus(Request $request) {
        return response()->json($this->updateUserAdapter->ChangeStatus($request->params));
    }
}
