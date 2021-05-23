<?php


namespace Core\Almacen\Unidad\Infraestructure\DataBase;


use App\Http\Excepciones\Exepciones;
use Core\Almacen\Unidad\Domain\Entity\UnidadEntity;
use Core\Almacen\Unidad\Domain\Repositories\UnidadRepository;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;

class UnidadSql implements UnidadRepository
{

    function Create(UnidadEntity $unidadEntity, $fecha_creacion)
    {
        try {
            $unidad= DB::table('unidad_medida')->insert([
                'um_name'=>$unidadEntity->UMNAME()->getUnidamedia(),
                'um_nombre_corto'=>$unidadEntity->UMNOMBRECORTO()->getNombrecorto(),
                'um_status' => 'active',
                'um_fecha_creacion' =>$fecha_creacion
            ]);
            if ($unidad) {
                return ['status'=>true , 'message' => 'unidad de Medida Registrada'];
            } else {
                return ['status'=>false , 'message' => 'Error al Registrada esta unidad de Medida'];
            }
        }catch (\Exception $exception) {
            return $exception->getMessage();
        }
    }

    function Update(UnidadEntity $unidadEntity, int $id, $fecha_creacion)
    {
        try {
            $unidad= DB::table('unidad_medida')->where('id_unidad_medida', $id)->update([
                'um_name'=>$unidadEntity->UMNAME()->getUnidamedia(),
                'um_nombre_corto'=>$unidadEntity->UMNOMBRECORTO()->getNombrecorto(),
                'um_fecha_creacion' =>$fecha_creacion
            ]);
            if ($unidad === 1) {
                return ['status'=>true , 'message' => 'unidad de Medida Actualizada'];
            } else {
                return ['status'=>false , 'message' => 'Error al Actualizar esta unidad de Medida'];
            }
        }catch (\Exception $exception) {
            return $exception->getMessage();
        }
    }

    function Read($params)
    {
        try {
            $numeroRecnum = $params['numeroRecnum'];
            $cantidadRegistros = $params['cantidadRegistros'];
            $query = DB::table('unidad_medida')
                ->where('um_status', '=', 'active')
                ->skip($numeroRecnum)
                ->take($cantidadRegistros)
                ->orderBy('id_unidad_medida', 'asc')
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
            $unidad = DB::table('unidad_medida')->where('id_unidad_medida', $id)->delete();
            if ($unidad === 1) {
                return ['status' => true, 'message' => 'Unidad Eliminado Correctamente'];
            }
            return ['status' => false, 'message' => 'Error al Eliminar Esta Unidad'];
        } else {
            return ['status' => true, 'message' => 'Unidad no existe en esta base de datos'];
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
            $query = DB::table('unidad_medida')->where('id_unidad_medida',$id)->update(['um_status'=>$status]);
            if ($query === 1) {
                return ['status'=>true, 'message'=>'Cambio de estado exitoso'];
            } else {
                return ['status'=>false, 'message'=>'Error al  Cambiar el estado'];
            }
        }catch (\Exception $exception) {
            return $exception->getMessage();
        }
    }

    function SearchUnidad($params)
    {
        try {
            $search = DB::table('unidad_medida')
                ->where('um_name', 'like', '%'.$params.'%')
                ->orWhere('um_code','like', '%'.$params.'%')
                ->where('um_status', '=', 'active')
                ->get();
            $ecepciones = new Exepciones(true, 'Unidad Encontradas', 200, $search);
            return $ecepciones->SendStatus();
        } catch (QueryException $exception) {
            $ecepciones = new Exepciones(false, $exception->getMessage(), $exception->getCode(), []);
            return $ecepciones->SendStatus();
        }
    }
}
