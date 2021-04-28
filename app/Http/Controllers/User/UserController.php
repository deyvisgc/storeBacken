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
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

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

    public function createUser(Request $request): \Illuminate\Http\JsonResponse
    {
        // User Data
        //return response()->json($request['people']['nameUser']);
        $nameUser= $request['people']['nameUser'];
        $password = $request['people']['password'];
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

        $user = new UserEntity(0, $nameUser,Hash::make($password),'ACTIVE',$token, 0, $idRol);
        $person = new PersonEntity(0, $name,$lastName,$address,$phone,$typePerson,$typeDocument,$docNumber);

        return response()->json($this->createUserAdapter->createUser($user,$person));
    }

    public function deleteUser($idUser): \Illuminate\Http\JsonResponse
    {
        return response()->json($this->deleteUserAdapter->deleteUser($idUser));
    }

    public function getUser(): \Illuminate\Http\JsonResponse
    {
        return response()->json($this->getUsersAdapter->getUser());
    }

    public function getUserById(int $idUser): \Illuminate\Http\JsonResponse
    {
        return response()->json($this->getUserByIdAdapter->getUserById($idUser));
    }

    public function updateUser(Request $request): \Illuminate\Http\JsonResponse
    {
        $name = $request['user']['nameUser'];
        $idRol = $request['user']['idRol'];
        $idUser = $request['user']['idUser'];
        $statusUser = $request['user']['statusUser'];

        $user = new UserEntity($idUser, $name, '', $statusUser, '', 0, $idRol);

        return response()->json($this->updateUserAdapter->updateUser($user));
    }

    public function getUserByIdPerson(int $idPersona): \Illuminate\Http\JsonResponse
    {
        return response()->json($this->getUserByIdPersonAdapter->getUserInfoByIdPerson($idPersona));
    }
}
