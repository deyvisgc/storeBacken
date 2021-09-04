<?php


namespace App\Repository\Almacen\Categorias;


use App\Http\Excepciones\Exepciones;
use Carbon\Carbon;
use Core\CortesCaja\Domain\ValueObjects\fechaDesde;
use Core\Traits\QueryTraits;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;

class CategoriaRepository implements CategoriaRepositoryInterface
{
    use QueryTraits;

    public function all($params)
    {
        try {
            $categoria = $this->Categorias($params->desde, $params->hasta, $params->id_clase);
            $subCategoria = $this->subCategoria($params->desde, $params->hasta, $params->id_clase);
            $exepciones =  new Exepciones(true, 'Categorias Encontradas', 200,['categoria'=>$categoria, 'subCate'=>$subCategoria]);
            return $exepciones->SendStatus();
        } catch (\Exception $exception) {
            $exepciones =  new Exepciones(false, $exception->getMessage(), $exception->getCode(),[]);
            return $exepciones->SendStatus();
        }
    }

    public function create($params)
    {
        try {
            $idclase=$params['id_categoria'];
            $categoria=$params['nombre_categoria'];
            $clase_superior=$params['clase_superior'];
            $createClass= new dtoCategoria($idclase, $categoria, $clase_superior);
            if ((int)$createClass->getId() === 0 ) { /*en este if inserto la nueva ctaegoria y subCategoria y agregar el codigo a cada catgoria o subtacategoria insertada*/
                $idClase =  DB::table('clase_producto')->insertGetId($createClass->create());
                $code = DB::select("SELECT concat('CP', (LPAD($idClase, 4, '0'))) as codigo");
                $update = DB::table('clase_producto')->where('id_clase_producto', $idClase)->update(['class_code'=>$code[0]->codigo]);
                $message = 'Registro exitoso';
                $messageError = 'Error al registrar';
            } else { /*en este else Actualizo la categoria*/
                if ((int)$createClass->getIdClasesuperior() === 0) {
                    $update = DB::table('clase_producto')->where('id_clase_producto', (int)$createClass->getId())->update($createClass->updateCategoria());
                } else {  /*Aqui hago la actualizacion para que la categoria registrada anteriormente sea una subcategoria*/
                    $update = DB::table('clase_producto')->where('id_clase_producto', (int)$createClass->getId())->update($createClass->updateSubCategoria());
                }
                $message = 'Actualizacón exitosa';
                $messageError = 'Error al Actualizar';
               }
            if ($update === 1) {
                $exepciones = new Exepciones(true,$message, 200, []);
            } else {
                $exepciones = new Exepciones(false,$messageError, 403, []);
            }
            return $exepciones->SendStatus();
        } catch (\Exception $exception) {
            $exepciones = new Exepciones(false,$exception->getMessage(), $exception->getCode(), []);
            return $exepciones->SendStatus();
        }
    }

    public function update(array $data, int $id)
    {
        // TODO: Implement update() method.
    }

    public function delete(int $id)
    {
        try {
            if ($id > 0) {
                $status = DB::table('clase_producto')->where('id_clase_producto', $id)->delete();
                if ($status === 1) {
                    $exepcion = new Exepciones(true,'Elimiando Correctamente', 200, []);
                } else {
                    $exepcion = new Exepciones(false,'Error al Eliminar', 403, []);
                }
            } else {
                $exepcion = new Exepciones(false,'Esta Categoria o Sub categoria no existe en nuestra base de datos', 403, []);
            }
            return $exepcion->SendStatus();
        } catch (\Exception $exception) {
            $exepcion = new Exepciones(false, $exception->getMessage(), $exception->getCode(), []);
            return $exepcion->SendStatus();
        }
    }

    public function find($params)
    {
        // TODO: Implement find() method.
    }

    public function show(int $id)
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

    public function selectCategoria($params)
    {
        try {
            $numeroRecnum = $params['numeroRecnum'];
            $cantidadRegistros = $params['cantidadRegistros'];
            $query = DB::select("select cp.clas_name, cp.id_clase_producto, cp.class_code, cp.clas_status from (select clas_id_clase_superior, clas_status from clase_producto where clas_id_clase_superior <> 0) as subclase,
                                   clase_producto as cp where cp.id_clase_producto = subclase.clas_id_clase_superior or cp.clas_id_clase_superior = 0 group by cp.clas_name, cp.id_clase_producto, cp.class_code, cp.clas_status
                                   order by cp.id_clase_producto asc LIMIT $cantidadRegistros OFFSET $numeroRecnum");
            if (count($query) === 0) { // aqui valido si existe una categoria en la subconsulta. Si no existe envio todas las categorias
                $query = DB::table('clase_producto')
                            ->where('clas_status', '=', 'active')
                            ->skip($numeroRecnum)
                            ->take($cantidadRegistros)
                            ->orderBy('id_clase_producto', 'DESC')
                            ->get();
            }
            if (count($query) < $cantidadRegistros) {  // Termina el scrol infinito
                $numberRecnum = 0;
                $noMore = true;
            }
            else {
                $numberRecnum = (int)$numeroRecnum + count($query);  // Sigue en proceso el scrol infinito
                $noMore = false;
            }
            $exepciones = new Exepciones(true,'', 200, ['categoria'=> $query, 'numeroRecnum' =>$numberRecnum, 'noMore' => $noMore]);
            return $exepciones->SendStatus();
        } catch (\Exception $exception) {
            $exepciones = new Exepciones(false,$exception->getMessage(), $exception->getCode(), []);
            return $exepciones->SendStatus();
        }
    }

    public function changeStatus($params)
    {
        $idclase=$params['id_clase_producto'];
        $status=$params['clas_status'];
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

    public function searchCategoria($texto)
    {
        try {
            $query =  DB::table('clase_producto');
            $query->select('clas_id_clase_superior', 'clas_status')->where('clas_id_clase_superior', '<>', 0);
            $subquery = DB::table('clase_producto as cp');
            $subquery->joinSub($query, 'sub', function($join){
                $join->on('cp.id_clase_producto', '=', 'sub.clas_id_clase_superior')
                    ->orWhere('cp.clas_id_clase_superior', 0);
                })->select('cp.*')
                ->where('cp.clas_name', 'like', '%'.$texto.'%')
                ->orWhere('cp.class_code', 'like', '%'.$texto.'%')
                ->where('cp.clas_status', '=', 'active')
                ->groupBy(['cp.id_clase_producto', 'cp.clas_name', 'cp.clas_id_clase_superior', 'cp.clas_status', 'cp.class_code', 'cp.fecha_creacion'
                ])->orderBy('cp.id_clase_producto', 'desc');
            $lista = $subquery->get();
            $ecepciones = new Exepciones(true, 'Categoria Encontradas', 200, $lista);
            return $ecepciones->SendStatus();
        } catch (QueryException $exception) {
            $ecepciones = new Exepciones(false, $exception->getMessage(), $exception->getCode(), []);
            return $ecepciones->SendStatus();
        }
    }

    // metodos para sub Categoria

    public function editSubCate($params)
    {
        try {
            $id_hijo = $params['id_hijo'];
            $id_padre = $params['id_padre'];
            $subcate = DB::select("select ch.clas_name as clas_hijo, ch.id_clase_producto as id_hijo,
                                      cp.clas_padre, cp.id_padre from ( select clas_name as clas_padre, id_clase_producto as id_padre
                                      from clase_producto where id_clase_producto = $id_padre) as cp ,clase_producto as ch
                                      where id_clase_producto = $id_hijo  and clas_id_clase_superior = $id_padre");
            if (count($subcate) === 0) {
                $message = 'No existe Información para esta Sub Categoria';
                $codigo  = 403;
                $status  = false;
            } else {
                $message = 'Información encontrada';
                $codigo  = 200;
                $status  = true;
            }

            $exepciones = new Exepciones($status, $message, $codigo, $subcate[0]);
            return $exepciones->SendStatus();

        } catch (\Exception $exception) {

            $exepciones = new Exepciones(false, $exception->getMessage(), $exception->getCode(), []);
            return $exepciones->SendStatus();

        }
    }

    public function selectSubCategoria($params)
    {
        return $this->obtenerSubCategoriaxIDPadre($params);
    }

    public function searchSubCate($params)
    {
        try {
            $texto = $params['params'];
            $query = DB::select("select cp.clas_name as clasepadre, subclase.clas_name as clasehijo,
                                       subclase.clas_status as statushijo, cp.clas_status as statuspadre, cp.id_clase_producto as idpadre,
                                       cp.clas_id_clase_superior, subclase.id_clase_producto as idhijo, subclase.class_code
                                       from (select clas_name,clas_id_clase_superior, clas_status,id_clase_producto, class_code from
                                       clase_producto where clas_id_clase_superior <> 0) as subclase,
                                       clase_producto as cp where cp.id_clase_producto = subclase.clas_id_clase_superior
                                       and (subclase.clas_name like '%$texto%' or subclase.class_code like '%$texto%')
                                       and subclase.clas_status = 'active' order by cp.id_clase_producto desc");
            $excepcion = new Exepciones(true,'Sub categoria encontradas', 200,$query);
            return $excepcion->SendStatus();
        } catch (QueryException $exception) {
            $exepciones = new Exepciones(false, $exception->getMessage(), $exception->getCode(),[]);
            return $exepciones->SendStatus();
        }
    }

}
