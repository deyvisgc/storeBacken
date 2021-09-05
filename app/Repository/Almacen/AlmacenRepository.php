<?php


namespace App\Repository\Almacen;


use App\Http\Excepciones\Exepciones;
use Illuminate\Support\Facades\DB;

class AlmacenRepository implements AlmacenRepositoryInterface
{

    public function all($params)
    {
        try {
            $lista = DB::table('almacen')->where('estado', '=', 'active')->get();
            $excepciones = new Exepciones(true, 'Encontrado', 200, $lista);
            return $excepciones->SendStatus();
        } catch (\Exception $exception) {
            $excepciones = new Exepciones(false, $exception->getMessage(), $exception->getCode(), []);
            return $excepciones->SendStatus();
        }
    }

    public function create($params)
    {
        // TODO: Implement create() method.
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
