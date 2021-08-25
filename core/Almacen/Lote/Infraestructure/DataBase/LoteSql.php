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

    }

    function Readxid(int $id)
    {
        try {
            if ($id > 0) {
              $lotes =  DB::table('lote')->where('id_product',$id)->get();
              if (count($lotes) > 0) {
                  $exepciones = new Exepciones(true,'Lotes encontrados', 200, ['lotes'=>$lotes]);
              } else {
                  $exepciones = new Exepciones(false,'No existe lotes para este producto', 403, []);
              }
              return $exepciones->SendStatus();
            } else {
                $exepciones = new Exepciones(false,'Este lote no existe en nuestra base de datos', 403, []);
                return $exepciones->SendStatus();
            }
        } catch (QueryException $exception) {
            $exepciones = new Exepciones(false,$exception->getMessage(), $exception->getMessage(), []);
            return $exepciones->SendStatus();
        }
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
            $typeRegistro= $params['typoRegistro'];
            $idLote = DB::table('product_por_lotes as l')
                ->join('product as p', 'l.id_product','=', 'p.id_product')
                ->where('p.pro_name',$nombreProducto)
                ->max('l.lot_code');
            if(empty($idLote)) {
                $idLote = 0;
                if ($idLote >= 0 && $idLote < 9) {
                    $lot = $idLote + 1;
                    $lote =  $idLote === 0 ? '01' : '0'. $lot;
                    $alias = 'L'.substr(strtoupper($nombreProducto), 0,3).$lote;
                    $exepciones = new Exepciones(true,'Codigo obtenido', 200,['codigo'=>$alias, 'lot_name'=>$lote]);
                    return $exepciones->SendStatus();
                }
            } else {
                if ($typeRegistro === 'RegisProducto') {
                    $exepciones = new Exepciones(false,'Este producto ya tiene registrado lotes. Registre desde la compra nuevos lotes', 403,[]);
                    return $exepciones->SendStatus();
                } else {
                    $numberSubstring = substr($idLote, 4,10000);
                    $primerNumber = (int)substr($numberSubstring, 0,1); // si el primer numero es cero se saca el numero que sigue y se suma mas uno
                    if ($primerNumber === 0) {
                        $number = (int)substr($numberSubstring, 1,1) + 1;
                        $lote = '0'.$number;
                    } else {
                        $lote = (int)substr($numberSubstring, 0,10000) + 1;
                    }
                    $alias = 'L'.substr(strtoupper($nombreProducto), 0,3).$lote;
                    $exepciones = new Exepciones(true,'Codigo obtenido', 200,['codigo'=>$alias, 'lot_name'=>$lote]);
                    return $exepciones->SendStatus();
                }

            }
        } catch (QueryException $exception) {
            $exepciones = new Exepciones(false,$exception->getMessage(), $exception->getCode(),[]);
            return $exepciones->SendStatus();
        }
    }
}
