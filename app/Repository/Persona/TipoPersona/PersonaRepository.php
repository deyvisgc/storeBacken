<?php


namespace App\Repository\Persona\TipoPersona;


use App\Http\Excepciones\Exepciones;
use App\Traits\QueryTraits;
use Carbon\Carbon;
use GuzzleHttp\Exception\BadResponseException;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;
use GuzzleHttp\Client;

class PersonaRepository implements PersonaRepositoryInterface
{
    use QueryTraits;

    public function all($params)
    {
        try {
            $desde = Carbon::parse($params['desde'])->format('Y-m-d');
            $hasta = Carbon::parse($params['hasta'])->format('Y-m-d');
            $numero = $params['numero'];
            $tipoDocumento = $params['tipoDocumento'];
            $departamento = $params['departamento'];
            $provincia = $params['provincia'];
            $distrito = $params['distrito'];
            $tipoPersona = $params['tipoPersona'];
            $tipo = $params['tipo']; // este es el tipo proveedor o tipo cliente
            $lista = $this->obtenerCliente(0, $desde, $hasta,$numero,$tipoDocumento,$departamento,$provincia,$distrito, $tipoPersona, $tipo);
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
            $tipoCliente = $params['tipoCliente'] ? $params['tipoCliente'] : 0;
            $departamento = $params['departamento'];
            $provincia = $params['provincia'];
            $distrito = $params['distrito'];
            $direccion = $params['direccion'];
            $telefono = $params['telefono'];
            $email = $params['email'];
            $typePersona = $params['typePersona'];
            $accion = $params['accion'];
            $person = new dtoPersona($idPersona, $nombre, $razonSocial, $tipoDocumento, $numeroDocumento, $fechaCreacion, $codigoInterno, $tipoCliente, $departamento, $provincia, $distrito, $direccion, $telefono, $email, $typePersona);
            $personData = $person->Person($accion);
            if ($idPersona === 0) { // esto es la opcion crear
                $status = DB::table('persona')->insert($personData);
                if ($status) {
                    $exepeciones = new Exepciones(true, 'Información registrada', 200, []);
                } else {
                    $exepeciones = new Exepciones(false, 'Error al registrar', 403, []);
                }
                return  $exepeciones->SendStatus();
            } else {
                DB::table('persona')->where('id_persona', $idPersona)->update($personData);
                $exepeciones = new Exepciones(true, 'Información actualizada', 200, []);
                return $exepeciones->SendStatus();
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

    public function delete($id)
    {
        try {
            if ($id > 0) {
                $status = DB::table('persona')->where('id_persona', $id)->delete();
                if ($status === 1) {
                    $exepcion = new Exepciones(true,'Elimiando Correctamente', 200, []);
                } else {
                    $exepcion = new Exepciones(false,'Error al Eliminar este cliente', 403, []);
                }
            } else {
                $exepcion = new Exepciones(false,'El cliente a eliminar no existe en la base de datos', 403, []);
            }
            return $exepcion->SendStatus();
        } catch (\Exception $exception) {
            $exepcion = new Exepciones(false, $exception->getMessage(), $exception->getCode(), []);
            return $exepcion->SendStatus();
        }
    }

    public function find($params)
    {

    }
    public function show(int $id)
    {
        try {
            $cliente = $this->obtenerCliente($id, '', '', '', '', '', '', '', '', '');
            $tipoCliente = $this->getTypePersona([]);
            $excepciones = new Exepciones(false, 'Información encontrada', 200, ['cliente'=>$cliente, 'tipoCliente'=>$tipoCliente]);
            return $excepciones->SendStatus();
        } catch (\Exception $exception) {
            $excepciones = new Exepciones(false, $exception->getMessage(), $exception->getCode(), []);
            return $excepciones->SendStatus();
        }
    }
    function getTypePersona($params)
    {
    }
    function searchPerson($client, $params)
    {
        try {
            $url = $params['typeSearch'];
            $numberDoc = $params['numeroDocumento'];
            $list = DB::table('persona')->where('per_numero_documento', $numberDoc)->first();
            if ($list) {
                $exepeciones = new Exepciones(true, 'Proveedor Encontrado', 200, $list);
                return $exepeciones->SendStatus();
            } else {
                return  $this->getAPi($client, $url, $numberDoc);
            }
        } catch (\Exception $exception) {
            $exepeciones = new Exepciones(false, $exception->getMessage(), $exception->getCode(), []);
            return $exepeciones->SendStatus();
        }
    }
    function getAPi($client, $url, $number) {
        try {
            $response = $client->request('get', "$url/". $number);
            $res = json_decode($response->getBody()->getContents());
            if ($url === 'dni') {
                $lista =  [
                    'per_nombre' => $res->nombres.' '.$res->apellidoPaterno. ' '. $res->apellidoMaterno,
                    'dni' => $res->dni
                ];
            } else {
                $lista = [
                    'per_razon_social' => $res->razonSocial,
                    'ruc' => $res->ruc
                ];
            }
            $exepeciones = new Exepciones(true, 'Proveedor Encontrado', 200, $lista);
            return $exepeciones->SendStatus();

        } catch (BadResponseException $e) {
            $exepeciones = new Exepciones(false, $e->getResponse()->getBody()->getContents(), $e->getCode(), []);
            return $exepeciones->SendStatus();

        }
    }
    function changeStatus($params)
    {
        try {
            if ($params['id'] > 0) {
                if ($params['status'] === 'active') {
                    $status = 'disable';
                } else {
                    $status = 'active';
                }
                $statusUpdate = DB::table('persona')->where('id_persona', $params['id'])->update(['per_status'=>$status]);
                if ($statusUpdate === 1) {
                    $excepcion= new Exepciones(true,'Estado  Actualizado Correctamente', 200, []);
                } else {
                    $excepcion= new Exepciones(false,'Error al cambiar de estado', 403, []);

                }
                return $excepcion->SendStatus();
            } else {
                $excepcion= new Exepciones(false,'Este cliente no existe', 403, []);
                return $excepcion->SendStatus();
            }
        } catch (\Exception $exception) {
            $excepcion= new Exepciones(false,$exception->getMessage(), $exception->getCode(), []);
            return $excepcion->SendStatus();
        }
    }
}
