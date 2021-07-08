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
            $exepciones =  new Exepciones(true, 'Categorias Encontradas', 200,['categoria'=>$categoria[0],'numeroRecnum'=>$categoria[1], 'noMore' => $categoria[2], 'subCate'=>$subCategoria]);
            return $exepciones->SendStatus();
        } catch (QueryException $exception) {
            $exepciones =  new Exepciones(false, $exception->getMessage(), $exception->getCode(),[]);
            return $exepciones->SendStatus();
        }
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
    function ChangeStatusSubCate(int $idclase, string $status)
    {
        try {
            if ($status === 'active') {
                $status = 'disable';
                $message = 'Sub categoria Desactivada correctamente';
                $messageError = 'Error al desactivar esta sub categoria';
            } else {
                $status = 'active';
                $message = 'Sub categoria Activada correctamente';
                $messageError = 'Error al activar esta sub categoria';
            }
            $query = DB::table('clase_producto')->where('id_clase_producto',$idclase)->update(['clas_status'=>$status]);
            if ($query === 1) {
                $exepciones = new Exepciones(true,$message, 200, []);
            } else {
                $exepciones = new Exepciones(false,$messageError, 403, []);
            }
            return $exepciones->SendStatus();
        }catch (\Exception $exception) {
            $exepciones = new Exepciones(false,$exception->getMessage(), $exception->getCode(), []);
            return $exepciones->SendStatus();
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
