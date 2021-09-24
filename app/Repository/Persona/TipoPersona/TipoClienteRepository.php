<?php


namespace App\Repository\Persona\TipoPersona;


use App\Http\Excepciones\Exepciones;
use Illuminate\Support\Facades\DB;

class TipoClienteRepository implements PersonaRepositoryInterface
{

    function searchPerson($client, $params)
    {
        // TODO: Implement searchPerson() method.
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
                $statusUpdate = DB::table('tipo_cliente_proveedor')->where('id', $params['id'])->update(['tipo_estado'=>$status]);
                if ($statusUpdate === 1) {
                    $excepcion= new Exepciones(true,'Estado  Actualizado Correctamente', 200, []);
                } else {
                    $excepcion= new Exepciones(false,'Error al cambiar de estado', 403, []);

                }
                return $excepcion->SendStatus();
            } else {
                $excepcion= new Exepciones(false,'Este tipo cliente no existe', 403, []);
                return $excepcion->SendStatus();
            }
        } catch (\Exception $exception) {
            $excepcion= new Exepciones(false,$exception->getMessage(), $exception->getCode(), []);
            return $excepcion->SendStatus();
        }
    }

    public function all($params)
    {
        try {
            $query = DB::table('tipo_cliente_proveedor')->orderByDesc('id')->get();
            $exepciones = new Exepciones(true, 'Informacion Encontrada', 200, $query);
            return $exepciones->SendStatus();
        } catch (\Exception $exception) {
            $exepciones = new Exepciones(false, $exception->getMessage(), $exception->getCode(), []);
            return $exepciones->SendStatus();
        }
    }

    public function create($params)
    {
        try {
            $tipo = new dtoTipoCliente($params['id'], $params['descripcion']);
            if ($tipo->getId() === 0) { // esto es el metodo crear
                $status = DB::table('tipo_cliente_proveedor')->insert($tipo->tipoCliente($params['accion']));
                if ($status) {
                    $exepciones = new Exepciones(true, 'Registro exitoso', 200, []);
                } else {
                    $exepciones = new Exepciones(false, 'Error al registrar', 403, []);
                }
                return  $exepciones->SendStatus();
            } else {
                DB::table('tipo_cliente_proveedor')->where('id', $tipo->getId())
                              ->update($tipo->tipoCliente($params['accion']));
                $exepciones = new Exepciones(true, 'Exito al actualizar', 200, []);
                return  $exepciones->SendStatus();
            }
        } catch (\Exception $exception) {
            $exepciones = new Exepciones(false, $exception->getMessage(), $exception->getCode(), []);

            return $exepciones->SendStatus();
        }
    }

    public function update(array $data, int $id)
    {
        // TODO: Implement update() method.
    }

    public function delete(int $id)
    {

        try {
            if ($id > 0) {
                $status = DB::table('tipo_cliente_proveedor')->where('id', $id)->delete();
                if ($status === 1) {
                    $exepcion = new Exepciones(true,'Elimiando Correctamente', 200, []);
                } else {
                    $exepcion = new Exepciones(false,'Error al Eliminar', 403, []);
                }
            } else {
                $exepcion = new Exepciones(false,'El tipo cliente a eliminar no existe en la base de datos', 403, []);
            }
            return $exepcion->SendStatus();
        } catch (\Exception $exception) {
            $exepcion = new Exepciones(false, $exception->getMessage(), $exception->getCode(), []);
            return $exepcion->SendStatus();
        }
    }

    public function find($params)
    {
        // TODO: Implement find() method.
    }

    public function show(int $id)
    {
        try {
            $query = DB::table('tipo_cliente_proveedor')->where('id', $id)->get();
            $exepciones = new Exepciones(true, 'Informacion Encontrada', 200, $query[0]);
            return $exepciones->SendStatus();
        } catch (\Exception $exception) {
            $exepciones = new Exepciones(false, $exception->getMessage(), $exception->getCode(), []);
            return $exepciones->SendStatus();
        }
    }
}
