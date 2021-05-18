<?php


namespace Core\Producto\Infraestructure\DataBase;


use App\Http\Excepciones\Exepciones;
use Core\Producto\Domain\Entity\ProductoEntity;
use Core\Producto\Domain\Repositories\ProductoRepository;
use Core\Traits\QueryTraits;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;

const   Code = '775820300317';
class ProductoSql implements ProductoRepository
{
    Use QueryTraits;
    function Create(ProductoEntity $productoEntity)
    {
        try {
              $create = DB::table('product')->insertGetId(
                    ['pro_name' => $productoEntity->Nombre()->getProNombre(),
                        'pro_precio_compra' => $productoEntity->PrecioCompra()->getProPrecioCompra(),
                        'pro_precio_venta' => $productoEntity->PrecioVenta()->getProPrecioVenta(),
                        'pro_cantidad' => $productoEntity->Cantidad()->getProCantidad(),
                        'pro_cantidad_min' => $productoEntity->CantidadMinima()->getProCantidadMinima(),
                        'pro_status' => 'active',
                        'pro_description' => $productoEntity->Descripcion()->getProDescripcion(),
                        'id_lote' => $productoEntity->IDLOTE()->getIdlote(),
                        'id_clase_producto' => $productoEntity->IDClaseProducto()->getIdclaseProducto(),
                        'id_unidad_medida' => $productoEntity->UnidadMedida()->getIdunidadmedida(),
                        'pro_cod_barra' => $productoEntity->Barra()->getBarra(),
                        'id_subclase' =>$productoEntity->IdSubclase()->getIdsubclase()
                    ]);
              $code = DB::select("SELECT concat('P', (LPAD($create, 4, '0'))) as codigo");
              $updaecode = DB::table('product')->where('id_product', $create)->update(['pro_code'=>$code[0]->codigo]);
            if ($updaecode == 1) {
                return ['status' => true, 'message' => 'Registro existo'];
            } else {
                return ['status' => false, 'message' => 'Error al registrar'];
            }
        } catch (\Exception $exception) {
            return $exception->getMessage();
        }

    }

    function Update(ProductoEntity $productoEntity, int $idproducto,$pro_code)
    {
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
                    ->join('lote as l', 'pro.id_lote', '=', 'l.id_lote')
                    ->join('clase_producto as cp', 'pro.id_clase_producto', '=', 'cp.id_clase_producto')
                    ->join('unidad_medida as um', 'pro.id_unidad_medida', '=', 'um.id_unidad_medida')
                    ->select('pro.*', 'cp.clas_name as clase', 'l.lot_name as lote', 'um.um_name as unidad')
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
            $Status = new Exepciones(true,'Su codigo de Barra es'.$codigoBarra,200,$codigoBarra);
            return $Status->SendError();
        } catch (QueryException $exception){
            $Status = new Exepciones(false, $exception->getMessage(), $exception->getCode(),null);
            return $Status->SendError();
        }
    }

    function Edit($params)
    {
        try {
            $idClase = $params['idClase'];
            $idProduct = $params['idProduct'];
            if ($idClase > 0 && $idProduct > 0) {
                $padre = $this->ClasePadre();
                $hijo = $this->Clasehijoxidpadre($idClase);
                $lote = DB::table('lote')
                        ->where('lot_status', '=', 'active')
                        ->get();
                $unidad = DB::table('unidad_medida')
                         ->where('um_status', '=', 'active')
                         ->get();
                $product = DB::table('product')->where('id_product', $idProduct)->first();
                $exepcion= new Exepciones(true, 'Producto Encontrado', 200, ['lote' => $lote, 'clapadre' => $padre,'clahijo'=>$hijo, 'unidad' => $unidad, 'product' => $product]);
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
