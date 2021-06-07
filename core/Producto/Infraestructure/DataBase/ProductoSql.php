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
use const Core\Reportes\Infraestructure\Database\result;

class ProductoSql implements ProductoRepository
{
    Use QueryTraits;
    function Create(ProductoEntity $productoEntity, $lote)
    {
        try {
           $isvalidate = $this->validarLote($lote);
           if (count($isvalidate) > 0) {
               $exepcion = new Exepciones(false, 'Error', 200, $isvalidate);
               return $exepcion->SendStatus();
           } else {
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
                       'lot_cantidad'=>$l['lot_cantidad'],
                       'lot_precio_compra' =>$l['lot_precio_compra'],
                       'lot_precio_venta' =>$l['lot_precio_venta'],
                       'lot_expiration_date'=>$l['lot_expiration_date'],
                       'lot_creation_date'=>$productoEntity->getFecha(),
                       'id_product'=>$idProducto
                   ]);
               }
               DB::commit();
               $exepcion = new Exepciones(true, 'Producto registrado correctamnete', 200, []);
               return $exepcion->SendStatus();
           }
        } catch (QueryException $exception) {
            $exepcion = new Exepciones(false, $exception->getMessage(), $exception->getCode(), []);
            DB::rollBack();
            return $exepcion->SendStatus();
        }
    }

    function Read($params)
    {
        try {
            $numeroRecnum = $params['numeroRecnum'];
            $cantidadRegistros = 20;
            $query = DB::table('product as pro');
            if ($params->idClase > 0) {
                $query->where('pro.id_clase_producto',$params->idClase);
            }
            if ($params->idUnidad > 0) {
                $query->where('pro.id_unidad_medida',$params->idUnidad);
            }
            if ($params->desde && $params->hasta) {
                $query->whereBetween('pro.pro_fecha_creacion',[$params->desde, $params->hasta]);
            }


            $query->leftJoin('clase_producto as subclase', 'pro.id_subclase', 'subclase.id_clase_producto')
                    ->leftJoin('clase_producto as cp', 'pro.id_clase_producto', '=', 'cp.id_clase_producto')
                    ->leftJoin('unidad_medida as um', 'pro.id_unidad_medida', '=', 'um.id_unidad_medida')
                    ->select('pro.*', 'cp.clas_name as clasePadre', 'subclase.clas_name as classHijo', 'um.um_name as unidad')
                    ->skip($numeroRecnum)
                    ->take($cantidadRegistros)
                    ->orderBy('id_product', 'Asc')
                    ->get();
            $result= $query->get();
            if (count($result) < $cantidadRegistros) {
                $numberRecnum = 0;
                $noMore = true;
            } else {
                $numberRecnum = (int)$numeroRecnum + count($result);
                $noMore = false;
            }
            $excepcion = new Exepciones(true,'Productos Encontrados', 200,['lista'=>$result, 'numeroRecnum'=>$numberRecnum,'noMore'=>$noMore]);
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

    private function validarLote($lote)
    {
        $detalleError = array();
        foreach ($lote as $item) {
            if ($item['lot_name'] === '') {
                $error = 'Nombre del lote es requerido';
                 array_push($detalleError, $error);
            }
            if ($item['lot_code'] === '') {
                $error = 'Codigo del lote'.$item['lot_name']. ' es requerido';
                array_push($detalleError, $error);
            }
            if ($item['precio_compra'] === 0  || !$item['precio_compra']) {
                $error = 'El precio de compra del lote '.$item['lot_name']. ' debe ser mayor a 0';
                array_push($detalleError, $error);
            }
            if ($item['precio_venta'] === 0 || !$item['precio_venta']) {
                $error = 'El precio de venta del lote '.$item['lot_name'].' debe ser mayor a 0';
                array_push($detalleError, $error);
            }
            if ($item['cantidad'] === 0 || !$item['cantidad']) {
                $error = 'El Lote '.$item['lot_name'].' tiene cantidad cero';
                array_push($detalleError, $error);
            }
            if ($item['lot_expiration_date'] === '') {
                $error = 'Fecha de vencimiento del lote '.$item['lot_name'].' es requerida';
                array_push($detalleError, $error);
            }
        }
        return $detalleError;
    }
}
