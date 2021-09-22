<?php


namespace App\Repository\Persona\TipoPersona;


use App\Http\Excepciones\Exepciones;
use Illuminate\Support\Facades\DB;

class TipoClienteRepository implements PersonaRepositoryInterface
{

    function getTypePersona($params)
    {

    }

    function searchPerson($client, $params)
    {
        // TODO: Implement searchPerson() method.
    }

    function changeStatus($params)
    {
        // TODO: Implement changeStatus() method.
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
        // TODO: Implement delete() method.
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
