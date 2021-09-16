<?php


namespace App\Repository\Persona\TipoPersona;


use App\Http\Excepciones\Exepciones;
use App\Traits\QueryTraits;
use Illuminate\Support\Facades\DB;

class PersonaRepository implements PersonaRepositoryInterface
{
    use QueryTraits;

    public function all($params)
    {
        try {
            $desde = $params['desde'];
            $hasta = $params['hasta'];
            $numero = $params['numero'];
            $tipoDocumento = $params['tipoDocumento'];
            $departamento = $params['departamento'];
            $provincia = $params['provincia'];
            $distrito = $params['distrito'];
            $lista = $this->obtenerCliente(0, $desde, $hasta,$numero,$tipoDocumento,$departamento,$provincia,$distrito);
            $exepeciones = new Exepciones(true, 'Informacion Encontrada', 200, $lista);
            return $exepeciones->SendStatus();
        } catch (\Exception $exception) {
            $exepeciones = new Exepciones(false, $exception->getMessage(), $exception->getCode(), []);
            return $exepeciones->SendStatus();
        }
    }

    public function create($params)
    {
        try {
            $idPersona = $params['idPersona'];
            $tipoDocumento = $params['typeDocumento'];
            $numeroDocumento = $params['numeroDocumento'];
            $nombre = $params['nombre'];
            $razonSocial = $params['razonSocial'];
            $fechaCreacion = $params['fechaCreacion'];
            $codigoInterno = $params['codigoInterno'];
            $tipoCliente = $params['tipoCliente'];
            $departamento = $params['departamento'];
            $provincia = $params['provincia'];
            $distrito = $params['distrito'];
            $direccion = $params['direccion'];
            $telefono = $params['telefono'];
            $email = $params['email'];
            $typePersona = $params['typePersona'];
            $accion = $params['accion'];
            $person = new dtoPersona($idPersona, $nombre, $razonSocial, $tipoDocumento, $numeroDocumento, $fechaCreacion, $codigoInterno, $tipoCliente, $departamento, $provincia, $distrito, $direccion, $telefono, $email, $typePersona);
            $status = $person->Person($accion);
            if ($idPersona === 0) { // esto es la opcion crear
                $status = DB::table('persona')->insert($status);
                if ($status) {
                    $exepeciones = new Exepciones(true, 'Exito al registrar', 200, []);
                } else {
                    $exepeciones = new Exepciones(false, 'Error al registrar', 403, []);
                }
                return  $exepeciones->SendStatus();
            } else {
                return 'accion actualizar';
            }
        } catch (\Exception $exception) {
            $exepeciones = new Exepciones(false, $exception->getMessage(), $exception->getCode(), []);
            return $exepeciones->SendStatus();
        }
    }

    public function update(array $data, int $id)
    {
        // TODO: Implement update() method.
    }

    public function delete(int $id)
    {
        // TODO: Implement delete() method.
    }

    public function find($params)
    {
        // TODO: Implement find() method.
    }

    public function show(int $id)
    {
        // TODO: Implement show() method.
    }
}
