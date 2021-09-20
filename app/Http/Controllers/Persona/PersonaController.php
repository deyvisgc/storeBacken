<?php


namespace App\Http\Controllers\Persona;


use App\Exports\Excel\Almacen\ExportProduct;
use App\Exports\Excel\Clientes\ExportClientes;
use App\Http\Controllers\Controller;
use App\Repository\Persona\Direccion\DireccionRepositoryInterface;
use App\Repository\Persona\TipoPersona\PersonaRepositoryInterface;
use App\Traits\QueryTraits;
use Barryvdh\DomPDF\Facade as PDF;
use Carbon\Carbon;
use GuzzleHttp\Client;
use Illuminate\Http\Request;
use Maatwebsite\Excel\Facades\Excel;

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
    use QueryTraits;
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
    function Exportar (Request $request) {
        $desde = Carbon::parse($request['desde'])->format('Y-m-d');
        $hasta = Carbon::parse($request['hasta'])->format('Y-m-d');
        $numero = $request['numero'];
        $tipoDocumento = $request['tipoDocumento'];
        $departamento = $request['departamento'];
        $provincia = $request['provincia'];
        $distrito = $request['distrito'];
        $tipoPersona = $request['tipoPersona'];
        $tipo = $request['tipo']; // este es el tipo proveedor o tipo cliente
        $opcion = $request->input('isExport');
        $lista = $this->obtenerCliente(0, $desde, $hasta,$numero,$tipoDocumento,$departamento,$provincia,$distrito, $tipoPersona, $tipo);
        if ($tipoPersona === 'cliente') {
            $titulo = 'Clientes';
        } else if ($tipoPersona === 'proveedor') {
            $titulo = 'Proveedores';
        }
        if ($opcion === 'excel') {
            return Excel::download(new ExportClientes($lista, $titulo), 'Clientes.xlsx')->deleteFileAfterSend (false);
        } else {
            $customPaper = array(0,0,710,710);
            $pdf = PDF::loadView('Exportar.Pdf.Cliente.Clientes', ['cliente'=>$lista, 'titulo'=>$titulo])->setPaper($customPaper);
            return $pdf->download('invoice.pdf');
        }
    }
}
