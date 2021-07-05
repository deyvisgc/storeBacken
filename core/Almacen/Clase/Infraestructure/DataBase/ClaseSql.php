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

    function Categoria(ClaseEntity $claseEntity)
    {
        try {
            if ((int)$claseEntity->idPadre->getIdpadre() === 0 ) {
                $idClase =  DB::table('clase_producto')->insertGetId($claseEntity->createCategoria());
                $code = DB::select("SELECT concat('CP', (LPAD($idClase, 4, '0'))) as codigo");
                $update = DB::table('clase_producto')->where('id_clase_producto', $idClase)->update(['class_code'=>$code[0]->codigo]);
                $message = 'Categoria registrada correctamente';
                $messageError = 'Error al registrar esta categoria';
                $codigo = 200;
            } else {
                if ((int)$claseEntity->IdClasesuperior()->getIdclasesupe() === 0) {
                    $update = DB::table('clase_producto')->where('id_clase_producto', (int)$claseEntity->idPadre->getIdpadre())->update($claseEntity->updateCategoria());
                } else {
                    $update = DB::table('clase_producto')
                        ->where('id_clase_producto', $claseEntity->idPadre->getIdpadre())
                        ->update($claseEntity->updateSubCategoria());
                }
                $message = 'Categoria Actualizada correctamente';
                $messageError = 'Error al Actualizar esta categoria';
                $codigo = 200;
            }
            if ($update === 1) {
                $exepciones = new Exepciones(true,$message, $codigo, []);
            } else {
                $exepciones = new Exepciones(false,$messageError, 403, []);
            }
            return $exepciones->SendStatus();
        } catch (\Exception $exception) {
            $exepciones = new Exepciones(false,$exception->getMessage(), $exception->getCode(), []);
            return $exepciones->SendStatus();
        }
    }

    function getCategoria($params)
    {
        try {
            $numeroRecnum = $params['numeroRecnum'];
            $cantidadRegistros = $params['cantidadRegistros'];
            $categoria = $this->Categorias($numeroRecnum, $cantidadRegistros);
            $subCategoria = $this->subCategoria();
            return $subCategoria;
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

    function editSubcate($params)
    {
        try {
            $id_hijo = $params['id_hijo'];
            $id_padre = $params['id_padre'];
            $subcate = DB::select("select ch.clas_name as clas_hijo, ch.id_clase_producto as id_hijo,
                                      cp.clas_padre, cp.id_padre from ( select clas_name as clas_padre, id_clase_producto as id_padre
                                      from clase_producto where id_clase_producto = $id_padre) as cp ,clase_producto as ch
                                      where id_clase_producto = $id_hijo  and clas_id_clase_superior = $id_padre");
            if (count($subcate) === 0) {
                $message = 'no existe Informacion para esta Sub Categoria';
                $codigo= 403;
                $status = false;
            } else {
                $message = 'Información encontrada';
                $codigo= 200;
                $status = true;
            }
            $exepciones = new Exepciones($status, $message, $codigo, $subcate[0]);
            return $exepciones->SendStatus();
        } catch (\Exception $exception) {
            $exepciones = new Exepciones(false, $exception->getMessage(), $exception->getCode(), []);
            return $exepciones->SendStatus();
        }
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
                $mensaje = 'Categoria Desactivada';
            } else {
                $status = 'active';
                $mensaje = 'Categoria Activada';
            }
            $query = DB::table('clase_producto')->where('id_clase_producto',$idclase)->update(['clas_status'=>$status]);
            if ($query === 1) {
                $exepciones = new Exepciones(true,$mensaje, 200,[]);
            } else {
                $exepciones = new Exepciones(false,'Error al Cambiar estado', 403,[]);
            }
           return $exepciones->SendStatus();
        }catch (\Exception $exception) {
            $exepciones = new Exepciones(false,$exception->getMessage(), $exception->getCode(),[]);
            return $exepciones->SendStatus();
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

    function editCategory($id)
    {
        try {
            $query = DB::table('clase_producto')
                    ->where('id_clase_producto', $id)
                    ->first();
            $excepciones = new Exepciones(true,'',200,$query);
            return $excepciones->SendStatus();
        } catch (\Exception $exception) {
            $excepciones = new Exepciones(false,$exception->getMessage(),$exception->getCode(),[]);

            return $excepciones->SendStatus();
        }
    }
}
