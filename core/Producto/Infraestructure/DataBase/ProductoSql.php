<?php


namespace Core\Producto\Infraestructure\DataBase;


use App\Http\Excepciones\Exepciones;
use Core\Producto\Domain\Entity\ProductoEntity;
use Core\Producto\Domain\Repositories\ProductoRepository;
use Core\Traits\QueryTraits;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\URL;
use Illuminate\Support\Facades\Storage;
const   Code = '775820300317';
use Illuminate\Support\Facades\File;
use Symfony\Component\HttpFoundation\BinaryFileResponse;

class ProductoSql implements ProductoRepository
{
    Use QueryTraits;
    function Create(ProductoEntity $productoEntity, $lote)
    {
        try {
            DB::beginTransaction();
            if ($productoEntity->getIdProducto() === 0) {
                $create = DB::table('product')->insertGetId($productoEntity->Create());
                $idProducto = $create;
                $code = DB::select("SELECT concat('P', (LPAD($create, 4, '0'))) as codigo");
                DB::table('product')->where('id_product', $create)->update(['pro_code'=>$code[0]->codigo]);
            } else {
                $create = DB::table('product')->where('id_product', $productoEntity->getIdProducto())->update($productoEntity->Update());
                DB::table('lote')->where('id_product', $productoEntity->getIdProducto())->delete();
                $idProducto = $productoEntity->getIdProducto();
            }
            foreach ($lote as $l) {
                DB::table('lote')->insertGetId([
                    'lot_name'=>$l['lot_name'],
                    'lot_code'=>$l['lot_code'],
                    'cantidad'=>$l['cantidad'],
                    'lot_expiration_date'=>$l['lot_expiration_date'],
                    'lot_creation_date'=>$productoEntity->getFecha(),
                    'id_product'=>$idProducto
                ]);
            }
            DB::commit();
            $exepcion = new Exepciones(true, 'Producto registrado correctamnete', 200, []);
            return $exepcion->SendStatus();
        } catch (QueryException $exception) {
            $exepcion = new Exepciones(false, $exception->getMessage(), $exception->getCode(), []);
            DB::rollBack();
            return $exepcion->SendStatus();
        }
    }

    function Update(ProductoEntity $productoEntity,$pro_code)
    {
        $idproducto = 0;
        try {
            if ($idproducto > 0) {
               $status = DB::table('product')->where('id_product', $idproducto)->update($productoEntity->Array($pro_code));
               if ($status === 1) {
                   $exepcion = new Exepciones(true,'Producto Actualizado Correctamente',200,[]);
               } else {
                   $exepcion = new Exepciones(false,'Error al Actualizar Producto',403,[]);

               }
            } else {
                $exepcion = new Exepciones(false,'Este producto no existe en nuestra base de datos',403,[]);
            }
            return $exepcion->SendStatus();
        } catch (\Exception $exception) {
            $exepcion = new Exepciones(false,$exception->getMessage(),$exception->getCode(),[]);
            return $exepcion->SendStatus();
        }
    }

    function Read($params)
    {
        try {
            $numeroRecnum = $params['numeroRecnum'];
            $cantidadRegistros = $params['numeroCantidad'];
            $query = DB::table('product as pro')
                    ->leftJoin('clase_producto as subclase', 'pro.id_subclase', 'subclase.id_clase_producto')
                    ->leftJoin('clase_producto as cp', 'pro.id_clase_producto', '=', 'cp.id_clase_producto')
                    ->leftJoin('unidad_medida as um', 'pro.id_unidad_medida', '=', 'um.id_unidad_medida')
                    ->select('pro.*', 'cp.clas_name as clasePadre', 'subclase.clas_name as classHijo', 'um.um_name as unidad')
                    ->skip($numeroRecnum)
                    ->take($cantidadRegistros)
                    ->orderBy('id_product', 'Asc')
                    ->get();
            if (count($query) < $cantidadRegistros) {
                $numberRecnum = 0;
                $noMore = true;
            } else {
                $numberRecnum = (int)$numeroRecnum + count($query);
                $noMore = false;
            }
            $excepcion = new Exepciones(true,'Productos Encontrados', 200,['lista'=>$query, 'numeroRecnum'=>$numberRecnum,'noMore'=>$noMore]);
            return $excepcion->SendStatus();
        } catch (QueryException $exception) {
            $excepcion = new Exepciones(false,$exception->getMessage(), $exception->getCode(),[]);
            return $excepcion->SendStatus();
        }
    }

    function delete(int $idproducto)
    {
        try {
            if ($idproducto > 0) {
               $status = DB::table('product')->where('id_product', $idproducto)->delete();
               if ($status === 1) {
                   $exepcion = new Exepciones(true,'Elimiando Correctamente', 200, []);
               } else {
                   $exepcion = new Exepciones(false,'Error al Eliminar este producto', 403, []);
               }
            } else {
                $exepcion = new Exepciones(false,'Este Producto no existe', 403, []);
            }
            return $exepcion->SendStatus();
        } catch (QueryException $exception) {
            $exepcion = new Exepciones(false, $exception->getMessage(), $exception->getCode(), []);
            return $exepcion->SendStatus();
        }

    }

    function CambiarStatus(string $status, int $id)
    {
        if ($id > 0) {
            if ($status === 'active') {
                $status = 'disable';
            } else {
                $status = 'active';
            }
            DB::table('product')->where('id_product', $id)->update(['pro_status'=>$status]);
            return ['status' => true, 'message' => 'Estado  Actualizado Correctamente'];
        } else {
            return ['status' => false, 'message' => 'Error al cambiar de estado'];
        }
    }

    function LastIdProduct()
    {
        try {
            $lastId = DB::table('product')->max('id_product');
            $lastId = $lastId + 1;
            $codigoBarra = Code.$lastId;
            $Status = new Exepciones(true,'Su codigo de Barra es'.$codigoBarra,200,['codigo'=>$codigoBarra]);
            return $Status->SendStatus();
        } catch (QueryException $exception){
            $Status = new Exepciones(false, $exception->getMessage(), $exception->getCode(),null);
            return $Status->SendStatus();
        }
    }

    function Edit($params)
    {
        try {
            $idClase = $params['idClase'];
            $idProduct = $params['idProduct'];
            if ($idClase > 0 && $idProduct > 0) {
                $hijo = $this->Clasehijoxidpadre($idClase);
                $product = DB::table('product as p')
                           ->join('clase_producto as cp', 'p.id_clase_producto', '=', 'cp.id_clase_producto')
                           ->leftJoin('clase_producto as subclase', 'p.id_subclase', 'subclase.id_clase_producto')
                           ->leftJoin('unidad_medida as u', 'p.id_unidad_medida', 'u.id_unidad_medida')
                           ->select('p.*','cp.clas_name as clasPadre', 'subclase.clas_name as classHijo', 'u.um_name')
                           ->where('p.id_product', $idProduct)->first();
                $lote = DB::table('lote')->where('id_product', $idProduct)->get();
                $exepcion= new Exepciones(true, 'Producto Encontrado', 200, ['clahijo'=>$hijo, 'product' => $product, 'lote'=>$lote]);
            } else {
                $exepcion= new Exepciones(false, 'Producto no existe', 403, []);
            }
            return $exepcion->SendStatus();
        } catch (QueryException $exception) {
            $exepcion= new Exepciones(false, $exception->getMessage(), $exception->getCode(), []);
            return $exepcion->SendStatus();
        }
    }
}
