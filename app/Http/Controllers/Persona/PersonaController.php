<?php


namespace App\Http\Controllers\Persona;


use App\Http\Controllers\Controller;
use Core\ManagePerson\Domain\Entity\PersonEntity;
use Core\ManagePerson\Infraestructura\AdapterBridge\ChangeStatusPersonAdapter;
use Core\ManagePerson\Infraestructura\AdapterBridge\CreatePersonAdapter;
use Core\ManagePerson\Infraestructura\AdapterBridge\DeletePersonAdapter;
use Core\ManagePerson\Infraestructura\AdapterBridge\GetPersonAdapter;
use Core\ManagePerson\Infraestructura\AdapterBridge\GetPersonByIdAdapter;
use Core\ManagePerson\Infraestructura\AdapterBridge\UpdatePersonAdapter;
use Illuminate\Http\Request;

class PersonaController extends Controller
{

    /**
     * @var CreatePersonAdapter
     */
    private CreatePersonAdapter $createPersonAdapter;
    /**
     * @var UpdatePersonAdapter
     */
    private UpdatePersonAdapter $updatePersonAdapter;
    /**
     * @var DeletePersonAdapter
     */
    private DeletePersonAdapter $deletePersonAdapter;
    /**
     * @var GetPersonByIdAdapter
     */
    private GetPersonByIdAdapter $getPersonByIdAdapter;
    /**
     * @var GetPersonAdapter
     */
    private GetPersonAdapter $getPersonAdapter;
    /**
     * @var ChangeStatusPersonAdapter
     */
    private ChangeStatusPersonAdapter $changeStatusPersonAdapter;

    public function __construct(
        CreatePersonAdapter $createPersonAdapter,
        UpdatePersonAdapter $updatePersonAdapter,
        DeletePersonAdapter $deletePersonAdapter,
        GetPersonByIdAdapter $getPersonByIdAdapter,
        GetPersonAdapter $getPersonAdapter,
        ChangeStatusPersonAdapter $changeStatusPersonAdapter
    )
    {
        $this->createPersonAdapter = $createPersonAdapter;
        $this->updatePersonAdapter = $updatePersonAdapter;
        $this->deletePersonAdapter = $deletePersonAdapter;
        $this->getPersonByIdAdapter = $getPersonByIdAdapter;
        $this->getPersonAdapter = $getPersonAdapter;
        $this->changeStatusPersonAdapter = $changeStatusPersonAdapter;
        $this->middleware('auth');
    }

    public function createPerson(Request $request) {
        $name = $request['person']['name'];
        $lastName = $request['person']['lastName'];
        $address = $request['person']['address'];
        $phone = $request['person']['phone'];
        $typePerson = $request['person']['typePerson'];
        $typeDocument = $request['person']['typeDocument'];
        $docNumber = $request['person']['docNumber'];

        $person = new PersonEntity(0, $name,$lastName,$address,$phone,$typePerson,$typeDocument,$docNumber);

        return response()->json($this->createPersonAdapter->createPerson($person));
    }

    public function deletePerson($idPersona) {
        return response()->json($this->deletePersonAdapter->deletePerson($idPersona));
    }

    public function getPerson() {
        return response()->json($this->getPersonAdapter->getPerson());
    }

    public function getPersonById(int $idPersona) {
        return response()->json($this->getPersonByIdAdapter->getPersonById($idPersona));
    }

    public function updatePerson(Request $request) {
        $idPersona = $request['person']['idPersona'];
        $name = $request['person']['name'];
        $lastName = $request['person']['lastName'];
        $address = $request['person']['address'];
        $phone = $request['person']['phone'];
        $typePerson = $request['person']['typePerson'];
        $typeDocument = $request['person']['typeDocument'];
        $docNumber = $request['person']['docNumber'];

        $person = new PersonEntity($idPersona,$name,$lastName,$address,$phone,$typePerson,$typeDocument,$docNumber);

        return response()->json($this->updatePersonAdapter->updatePerson($person));
    }

    public function changeStatusPerson(Request $request) {
        $idPersona = $request['idPerson'];
        return response()->json($this->changeStatusPersonAdapter->changeStatusPerson($idPersona));
    }
}
