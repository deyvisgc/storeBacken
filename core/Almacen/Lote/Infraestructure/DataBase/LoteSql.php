<?php


namespace Core\Almacen\Lote\Infraestructure\DataBase;


use App\Http\Excepciones\Exepciones;
use Core\Almacen\Lote\Domain\Entity\LoteEntity;
use Core\Almacen\Lote\Domain\Repositories\LoteRepository;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;

class LoteSql implements LoteRepository
{
    function Create(LoteEntity $loteEntity)
    {
        $lote = DB::table('lote')->insert([
            'lot_name' => $loteEntity->Lotname()->getLotname(),
            'lot_status' => 'active',
            'lot_codigo' => $loteEntity->Lotcodigo()->getLotcodigo(),
            'lot_expiration_date' => $loteEntity->Loteespiradate()->getExpridatedate(),
            'lot_creation_date' => $loteEntity->LotCreationDate()->getLotecreadate()
        ]);
        if ($lote == true) {
            return ['status' => true, 'message' => 'Lote Registrado Correctamente'];
        }
        return ['status' => false, 'message' => 'Error al Registrar Este lote'];
    }

    function Update(LoteEntity $loteEntity, int $id)
    {
        $lote = DB::table('lote')->where('id_lote', $id)
            ->update([
                'lot_name' => $loteEntity->Lotname()->getLotname(),
                'lot_codigo' => $loteEntity->Lotcodigo()->getLotcodigo(),
                'lot_expiration_date' => $loteEntity->Loteespiradate()->getExpridatedate(),
                'lot_creation_date' => $loteEntity->LotCreationDate()->getLotecreadate()]);
        if ($lote == 1) {
            return ['status' => true, 'message' => 'Lote Actualizado Correctamente'];
        }
        return ['status' => false, 'message' => 'Error al Actualizar Este lote'];
    }

    function Read($params)
    {
        try {
            $numeroRecnum = $params['numeroRecnum'];
            $cantidadRegistros = $params['cantidadRegistros'];
            $query = DB::table('lote')
                     ->where('lot_status', '=', 'active')
                     ->skip($numeroRecnum)
                     ->take($cantidadRegistros)
                     ->orderBy('id_lote', 'DESC')
                     ->get();
            if (count($query) < $cantidadRegistros) {
                $numberRecnum = 0;
                $noMore = true;

            } else {
                $numberRecnum = (int)$numeroRecnum + count($query);
                $noMore = false;
            }
            $excepcion = new Exepciones(true,'Lotes Encontrados', 200,['lista'=>$query, 'numeroRecnum'=>$numberRecnum,'noMore'=>$noMore]);
            return $excepcion->SendStatus();
        } catch (QueryException $exception) {
            $excepcion = new Exepciones(false,$exception->getMessage(), $exception->getCode(),[]);
            return $excepcion->SendStatus();
        }
    }

    function Readxid(int $id)
    {
        // TODO: Implement Readxid() method.
    }

    function delete(int $id)
    {
        if ($id > 0) {
            $lote = DB::table('lote')->where('id_lote', $id)->delete();
            if ($lote == 1) {
                return ['status' => true, 'message' => 'Lote Eliminado Correctamente'];
            }
            return ['status' => false, 'message' => 'Error al Eliminar Este lote'];
        } else {
            return ['status' => true, 'message' => 'Lote no existe en esta base de datos'];
        }
    }

    function CambiarStatus(int $id, string $status)
    {

        try {
            if ($status === 'active') {
                $status = 'disable';
            } else {
                $status = 'active';
            }
            $query = DB::table('lote')->where('id_lote',$id)->update(['lot_status'=>$status]);
            if ($query === 1) {
                return ['status'=>true, 'message'=>'Cambio de estado exitoso'];
            } else {
                return ['status'=>false, 'message'=>'Error al  Cambiar el estado'];
            }
        }catch (\Exception $exception) {
            return $exception->getMessage();
        }
    }

    function SearchLotes($params)
    {
        try {
            $search = DB::table('lote')
                ->where('lot_name', 'like', '%'.$params.'%')
                ->orWhere('lot_code','like', '%'.$params.'%')
                ->where('lot_status', '=', 'active')
                ->get();
            $ecepciones = new Exepciones(true, 'Lote Encontrados', 200, $search);
            return $ecepciones->SendStatus();
        } catch (QueryException $exception) {
            $ecepciones = new Exepciones(false, $exception->getMessage(), $exception->getCode(), []);
            return $ecepciones->SendStatus();
        }
    }
}
