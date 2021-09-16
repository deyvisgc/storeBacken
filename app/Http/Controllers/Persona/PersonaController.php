<?php


namespace App\Http\Controllers\Persona;


use App\Http\Controllers\Controller;
use App\Repository\Persona\Direccion\DireccionRepositoryInterface;
use App\Repository\Persona\TipoPersona\PersonaRepository;
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
    private DireccionRepositoryInterface $repository;
    private PersonaRepository $personaRepository;

    public function __construct(DireccionRepositoryInterface $repository, PersonaRepository $personaRepository)
    {
        $this->repository = $repository;
        $this->personaRepository = $personaRepository;
        $this->middleware('auth');
    }
    function getDepartamento(Request  $request) {
        return response()->json($this->repository->getDepartamento($request));
    }
    function getProvincia(Request  $request) {
        return response()->json($this->repository->getProvincia($request));
    }
    function getDistrito(Request  $request) {
        return response()->json($this->repository->getDistrito($request));
    }
    function searchDepartamento(Request  $request) {
        return response()->json($this->repository->searchDepartamento($request->params));
    }
    function searchProvincia(Request  $request) {
        return response()->json($this->repository->searchProvincia($request->params));
    }
    function searchDistrito(Request  $request) {
        return response()->json($this->repository->searchDistrito($request->params));
    }
    // Modulo Persona
    function createPerson(Request $request) {
        return response()->json($this->personaRepository->create($request->params));
    }
    function getPerson(Request $request) {
        return response()->json($this->personaRepository->all($request));
    }
    function deletePerson(Request $request) {
        // return response()->json($this->deletePersonAdapter->deletePerson($request->idPerson));
    }
    function getPersonById(int $idPersona) {
        // return response()->json($this->getPersonAdapter->getPersonById($idPersona));
    }
  /*  function updatePerson(Request $request) {
        $perfil = $request['person']['perfil'];
        $idPersona = $request['person']['idPerson'];
        $name = $request['person']['name'];
        $lastName = $request['person']['lastName'];
        $address = $request['person']['address'];
        $phone = $request['person']['phone'];
        $typeDocument = $request['person']['typeDocument'];
        $docNumber = $request['person']['docNumber'];
        $razonSocial = empty($request['person']['per_razon_social']) ? null : $request['person']['per_razon_social'];
        $person = new PersonEntity($idPersona,$name,$lastName,$address,$phone,null,$typeDocument,$docNumber,$razonSocial);
        return response()->json($this->updatePersonAdapter->updatePerson($person, $perfil));
    }
  */
    function updateStatusPerson(Request $request) {
        // return response()->json($this->updatePersonAdapter->updateStatusPerson($request->person));
    }
}
