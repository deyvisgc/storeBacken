<?php


namespace App\Repository\Compras;


use App\Http\Excepciones\Exepciones;
use Illuminate\Support\Facades\DB;

class ComprasRepository implements ComprasRepositoryInterface
{

    public function all($params)
    {
        // TODO: Implement all() method.
    }

    public function create($params)
    {
        // TODO: Implement create() method.
    }

    public function update(array $data, $id)
    {
        // TODO: Implement update() method.
    }

    public function delete($id)
    {
        // TODO: Implement delete() method.
    }

    public function find($params)
    {
        return $params;
    }

    function getSerie($params)
    {
        try {
            $lista = DB::table('serie_compra')->where('tipo_comprobante', (int)$params['tipo_comprobante'])->first();
            $exepcion = new Exepciones(true, '', 200, $lista);
           return $exepcion->SendStatus();
        }catch (\Exception $exception) {
            $exepcion = new Exepciones(false, $exception->getMessage(), $exception->getCode(), []);
            return $exepcion->SendStatus();
        }
    }

    public function show(int $id)
    {
        // TODO: Implement show() method.
    }
}
