<?php


namespace App\Http\Controllers\Persona;


use App\Http\Controllers\Controller;
use App\Repository\Persona\Direccion\DireccionRepositoryInterface;
use App\Repository\Persona\TipoPersona\PersonaRepository;
use App\Repository\Persona\TipoPersona\PersonaRepositoryInterface;
use Core\ManagePerson\Domain\Entity\PersonEntity;
use Core\ManagePerson\Infraestructura\AdapterBridge\ChangeStatusPersonAdapter;
use Core\ManagePerson\Infraestructura\AdapterBridge\CreatePersonAdapter;
use Core\ManagePerson\Infraestructura\AdapterBridge\DeletePersonAdapter;
use Core\ManagePerson\Infraestructura\AdapterBridge\GetPersonAdapter;
use Core\ManagePerson\Infraestructura\AdapterBridge\GetPersonByIdAdapter;
use Core\ManagePerson\Infraestructura\AdapterBridge\UpdatePersonAdapter;
use GuzzleHttp\Client;
use Illuminate\Http\Request;

class PersonaController extends Controller
{
    private DireccionRepositoryInterface $repository;
    private PersonaRepositoryInterface $personaRepository;
    private $client;
    public function __construct(DireccionRepositoryInterface $repository, PersonaRepositoryInterface $personaRepository, Client $client)
    {
        $this->repository = $repository;
        $this->personaRepository = $personaRepository;
        $this->client = $client;
        $this->middleware('auth');
    }
    // Modulo dirccion
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
    public function searchPerson(Request $request) {
        return response()->json($this->personaRepository->searchPerson($this->client,$request));
    }
    function getPersonById(int $idPersona) {
        return response()->json($this->personaRepository->show($idPersona));
    }
    function deletePerson(int $id) {
        return response()->json($this->personaRepository->delete($id));
    }
    function changeStatus(Request $request) {
        return response()->json($this->personaRepository->changeStatus($request->params));
    }
}
