<?php


namespace App\Http\Controllers\User;


use App\Http\Controllers\Controller;
use Core\ManagePerson\Domain\Entity\PersonEntity;
use Core\ManageUsers\Domain\Entity\UserEntity;
use Core\ManageUsers\Infraestructura\AdapterBridge\CreateUserAdapter;
use Core\ManageUsers\Infraestructura\AdapterBridge\DeleteUserAdapter;
use Core\ManageUsers\Infraestructura\AdapterBridge\GetUserByIdAdapter;
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

    public function __construct(
        CreateUserAdapter $createUserAdapter,
        DeleteUserAdapter $deleteUserAdapter,
        UpdateUserAdapter $updateUserAdapter,
        GetUsersAdapter $getUsersAdapter,
        GetUserByIdAdapter $getUserByIdAdapter
    )
    {
        $this->createUserAdapter = $createUserAdapter;
        $this->deleteUserAdapter = $deleteUserAdapter;
        $this->updateUserAdapter = $updateUserAdapter;
        $this->getUsersAdapter = $getUsersAdapter;
        $this->getUserByIdAdapter = $getUserByIdAdapter;
    }

    public function createUser(Request $request): \Illuminate\Http\JsonResponse
    {
        // User Data
        $name = $request['nameUser'];
        $password = $request['password'];
        $idRol = $request['idRol'];
        $token = base64_encode(str_random(50));

        // person data
        $name = $request['name'];
        $lastName = $request['lastName'];
        $address = $request['address'];
        $phone = $request['phone'];
        $typePerson = $request['typePerson'];
        $typeDocument = $request['typeDocument'];
        $docNumber = $request['docNumber'];

        $user = new UserEntity(0, $name,Hash::make($password),'ACTIVE',$token, 0, $idRol);
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
        $name = $request['nameUser'];
        $idRol = $request['idRol'];
        $idUser = $request['idUser'];
        $statusUser = $request['statusUser'];

        $user = new UserEntity($idUser, $name, '', $statusUser, '', 0, $idRol);

        return response()->json($this->updateUserAdapter->updateUser($user));
    }
}
