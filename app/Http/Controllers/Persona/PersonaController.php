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
        GetPersonAdapter $getPersonAdapter
    )
    {
        $this->createPersonAdapter = $createPersonAdapter;
        $this->updatePersonAdapter = $updatePersonAdapter;
        $this->deletePersonAdapter = $deletePersonAdapter;
        $this->getPersonAdapter = $getPersonAdapter;
        $this->middleware('auth');
    }
    function getPerson() {
        return response()->json($this->getPersonAdapter->getPerson());
    }
    function createPerson(Request $request) {
        $razonSocial = $request->person['per_razon_social'];
        $tipoDocumento = $request->person['tipoDocumento'];
        $numerDocumento = $request->person['numeroDocumento'];
        $telefono = $request->person['telefono'];
        $direccion = $request->person['direccion'];
        $typePerson = $request->person['typePeron'];
        return response()->json($this->createPersonAdapter->createPerson($razonSocial,$tipoDocumento,$numerDocumento,$telefono,$direccion,$typePerson));
    }

    function deletePerson($idPersona) {
        return response()->json($this->deletePersonAdapter->deletePerson($idPersona));
    }

     function getPersonById(int $idPersona) {
        return response()->json($this->getPersonByIdAdapter->getPersonById($idPersona));
    }

    function updatePerson(Request $request) {
        $perfil = $request['person']['perfil'];
        $idPersona = $request['person']['idPersona'];
        $name = $request['person']['name'];
        $lastName = $request['person']['lastName'];
        $address = $request['person']['address'];
        $phone = $request['person']['phone'];
        $typePerson = $request['person']['typePerson'];
        $typeDocument = $request['person']['typeDocument'];
        $docNumber = $request['person']['docNumber'];

        $person = new PersonEntity($idPersona,$name,$lastName,$address,$phone,$typePerson,$typeDocument,$docNumber);

        return response()->json($this->updatePersonAdapter->updatePerson($person, $perfil));
    }
     function changeStatusPerson(Request $request) {
        $idPersona = $request['idPerson'];
        return response()->json($this->changeStatusPersonAdapter->changeStatusPerson($idPersona));
    }
}
