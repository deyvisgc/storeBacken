<?php


namespace App\Repository\Almacen\Lotes;


use App\Http\Excepciones\Exepciones;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;

class LoteRepository implements lotRepositoryInterface
{

    public function all($params)
    {
        try {
            $numeroRecnum = $params['numeroRecnum'];
            $cantidadRegistros = $params['cantidadRegistros'];
            $idLote = $params['idLote'];
            $query = DB::table('product_por_lotes');
            if($idLote) {
                $query->where('id_lote', $idLote);
            }
            $query->where('lot_status', '=', 'active')
                ->skip($numeroRecnum)
                ->take($cantidadRegistros)
                ->orderBy('id_lote', 'DESC');
            $lista = $query->get();
            if (count($lista) < $cantidadRegistros) {
                $numberRecnum = 0;
                $noMore = true;
            } else {
                $numberRecnum = (int)$numeroRecnum + count($lista);
                $noMore = false;
            }
            $excepcion = new Exepciones(true,'Lotes Encontrados', 200,['lista'=>$lista, 'numeroRecnum'=>$numberRecnum,'noMore'=>$noMore]);
            return $excepcion->SendStatus();
        } catch (QueryException $exception) {
            $excepcion = new Exepciones(false,$exception->getMessage(), $exception->getCode(),[]);
            return $excepcion->SendStatus();
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
