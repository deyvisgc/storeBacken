<?php


namespace Core\Almacen\Clase\Infraestructure\DataBase;


use App\Http\Excepciones\Exepciones;
use Core\Almacen\Clase\Domain\Entity\ClaseEntity;
use Core\Almacen\Clase\Domain\Repositories\ClaseRepository;
use Core\Traits\QueryTraits;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;

class ClaseSql implements ClaseRepository
{
    use QueryTraits;

    function Create(ClaseEntity $claseEntity)
    {
        $regis=  DB::table('clase_producto')->insert(
            [
                'clas_name'=> $claseEntity->Classname()->getClassName(),
                'clas_id_clase_superior'=> $claseEntity->IdClasesuperior()->getIdclasesupe(),
                'clas_status' => 'active'
            ]);
        return $regis;
    }

    function getCategoria($params)
    {
        try {
            $numeroRecnum = $params['numeroRecnum'];
            $cantidadRegistros = $params['cantidadRegistros'];
            $query = DB::table('clase_producto')
                ->where('clas_status', '=', 'active')
                ->skip($numeroRecnum)
                ->take($cantidadRegistros)
                ->orderBy('id_clase_producto', 'asc')
                ->get();
            if (count($query) < $cantidadRegistros) {
                $numberRecnum = 0;
                $noMore = true;

            } else {
                $numberRecnum = (int)$numeroRecnum + count($query);
                $noMore = false;
            }
            return ['lista'=>$query, 'numeroRecnum'=>$numberRecnum,'noMore'=>$noMore];
        } catch (QueryException $exception) {
            return $exception->getMessage();
        }
    }
    function getclasepadre()
    {
        return $this->ClasePadre();
    }

    function delete(int $id)
    {
        // TODO: Implement delete() method.
    }

    function CambiarStatus(int $id)
    {
        // TODO: Implement CambiarStatus() method.
    }

    function ObtenerPadreehijoclase()
    {
        $cate = $this->Read();
        $query= $this->Padreehijoclase();
        return array('categorias'=>$cate, 'padreehijos'=>$query);
    }

    function Obtenerclasexid($idpadre)
    {
        $padres = $this->ClasePadre();
        $hijos = $this->Clasehijo();
        return array('padres' => $padres, 'hijos'=> $hijos);
    }

    function Update(array $data)
    {
        try {
            $idpadre = $data['id_clase_producto'];
            $idhijo = $data['clas_id_clase_superior'];
            $status = DB::table('clase_producto')->where('id_clase_producto',$idhijo)->
                      update(['clas_id_clase_superior' =>$idpadre]);
            if ($status === 1) {
                return ['status'=>true, 'message' => 'Actualizado Correctamente'];
            } else {
                return ['status'=>false, 'message' => 'Error al Actualizar'];
            }
        }catch (\Exception $exception) {
            return $exception->getMessage();
        }
    }

    function viewchild(int $idpadre)
    {
        return $this->Clasehijoxidpadre($idpadre);
    }

    function Actualizarcate(int $idclase, string $nombrecate)
    {
        try {
            $query = DB::table('clase_producto')->where('id_clase_producto',$idclase)->update(['clas_name'=>$nombrecate]);
            if ($query === 1) {
                return ['status'=>true, 'message'=>'Categoria Actualizada Correctamente'];
            } else {
                return ['status'=>false, 'message'=>'Error al  Actualizar esta Categoria'];
            }
        }catch (\Exception $exception) {
            return  $exception->getMessage();
        }
    }

    function ChangeStatusCate(int $idclase, string $status)
    {
        try {
            if ($status === 'active') {
                $status = 'disable';
            } else {
                $status = 'active';
            }
            $query = DB::table('clase_producto')->where('id_clase_producto',$idclase)->update(['clas_status'=>$status]);
            if ($query === 1) {
                return ['status'=>true, 'message'=>'Estado de esta categoria canbiada'];
            } else {
                return ['status'=>false, 'message'=>'Error al  Cambiar el estado de esta actegoria'];
            }
        }catch (\Exception $exception) {
            return $exception->getMessage();
        }
    }

    function ChangeStatusCateRecursiva(int $idclase, string $status)
    {
        try {
            if ($status === 'active') {
                $status = 'disable';
            } else {
                $status = 'active';
            }
            $query = DB::table('clase_producto')->where('id_clase_producto',$idclase)->update(['clas_status'=>$status]);
            if ($query === 1) {
                return ['status'=>true, 'message'=>'Estado de esta categoria canbiada'];
            } else {
                return ['status'=>false, 'message'=>'Error al  Cambiar el estado de esta actegoria'];
            }
        }catch (\Exception $exception) {
            return $exception->getMessage();
        }
    }

    function searchCategoria($params)
    {
        try {
            $search = DB::table('clase_producto')
                ->where('clas_name', 'like', '%'.$params.'%')
                ->orWhere('class_code','like', '%'.$params.'%')
                ->where('clas_status', '=', 'active')
                ->get();
            $ecepciones = new Exepciones(true, 'Categoria Encontradas', 200, $search);
            return $ecepciones->SendStatus();
        } catch (QueryException $exception) {
            $ecepciones = new Exepciones(false, $exception->getMessage(), $exception->getCode(), []);
            return $ecepciones->SendStatus();
        }
    }
}
