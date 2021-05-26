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

    function obtenerCode($params)
    {
        try {
            $nombreProducto= $params['pro_nombre'];
            $idLote = DB::table('lote as l')
                ->join('product as p', 'l.id_product','=', 'p.id_product')
                ->where('p.pro_name',$nombreProducto)
                ->max('l.lot_code');
            // $lote = 'LYOG0000001';
            if(empty($idLote)) {
                $idLote = 0;
            } else {
                $res =  substr($idLote, 4, 9);
                $numOne = (int)substr($res, 0, 1);
                $numTwo = (int)substr($res, 1, 2);
                $numTree = (int)substr($res, 2, 3);
                $numFor = (int)substr($res, 3, 4);
                if ($numOne > 0) {
                    $rpta =  substr($res, 0, 5);
                } else if ($numTwo > 0) {
                    $rpta =  substr($res, 1, 4);
                } else if ($numTree > 0) {
                    $rpta =  substr($res, 2, 3);
                } else if ($numFor > 0) {
                    $rpta =  substr($res, 3, 2);
                } else {
                    $rpta =  substr($res, 4, 1);
                }
                $idLote = $rpta;
            }
            if ($idLote > 0 && $idLote < 9) {
                $lot = $idLote + 1;
                $lote =  $idLote === 0 ? '01' : '0'. $lot;
            } else {
                $lote = $idLote + 1;
            }
            $alias = 'L'.substr(strtoupper($nombreProducto), 0,3);
            $lastId = $idLote + 1;
            $code = DB::select("SELECT concat('".$alias."', (LPAD($lastId, 5, '0'))) as codigo");
            $exepciones = new Exepciones(true,'Codigo obtenido', 200,[$code[0], 'lot_name'=>$lote]);
            return $exepciones->SendStatus();
        } catch (QueryException $exception) {
            $exepciones = new Exepciones(false,$exception->getMessage(), $exception->getCode(),[]);
            return $exepciones->SendStatus();
        }
    }
}
