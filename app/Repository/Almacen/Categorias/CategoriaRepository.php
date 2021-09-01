<?php


namespace App\Repository\Almacen\Categorias;


use App\Http\Excepciones\Exepciones;
use Carbon\Carbon;
use Core\CortesCaja\Domain\ValueObjects\fechaDesde;
use Core\Traits\QueryTraits;
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
            if ((int)$createClass->getIdPadre() === 0 ) { /*en este if inserto la nueva ctaegoria y agrego el codigo a cada codigo insertado*/
                $idClase =  DB::table('clase_producto')->insertGetId($createClass->create());
                $code = DB::select("SELECT concat('CP', (LPAD($idClase, 4, '0'))) as codigo");
                $update = DB::table('clase_producto')->where('id_clase_producto', $idClase)->update(['class_code'=>$code[0]->codigo]);
                $message = 'Categoria registrada correctamente';
                $messageError = 'Error al registrar esta categoria';
                $codigo = 200;
            } else { /*en este else Actualizo la categoria*/
                if ((int)$createClass->getIdClasesuperior() === 0) {
                    $update = DB::table('clase_producto')->where('id_clase_producto', (int)$createClass->getIdPadre())->update($createClass->updateCategoria());
                    $message = 'Categoria Actualizada correctamente';
                    $messageError = 'Error al Actualizar esta categoria';
                } else {
                    /*
                    $update = DB::table('clase_producto')
                        ->where('id_clase_producto', $claseEntity->idPadre->getIdpadre())
                        ->update($claseEntity->updateSubCategoria());
                    */
                }
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
                $query = DB::table('clase_producto')->get();
                return $query;
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
}
