<?php


namespace Core\Producto\Infraestructure\DataBase;


use App\Http\Excepciones\Exepciones;
use Core\Producto\Domain\Entity\ProductoEntity;
use Core\Producto\Domain\Repositories\ProductoRepository;
use Core\Traits\QueryTraits;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;
const Code = '775820300317';


class ProductoSql implements ProductoRepository
{
    Use QueryTraits;
    function Create(ProductoEntity $productoEntity, $lote)
    {
        try {
            switch (count($lote)) {
                case 1:
                    $isvalidate = $this->validarLote($lote);
                    if (count($isvalidate) > 0) {
                        $exepcion = new Exepciones(false, 'Error', 200, $isvalidate);
                        return $exepcion->SendStatus();
                    }
                    DB::beginTransaction();
                    if ($productoEntity->getIdProducto() === 0) {
                        $create = DB::table('product')->insertGetId($productoEntity->Create());
                        $idProducto = $create;
                        $code = DB::select("SELECT concat('P', (LPAD($create, 4, '0'))) as codigo");
                        DB::table('product')->where('id_product', $create)->update(['pro_code'=>$code[0]->codigo]);
                        $message = 'Producto registrado correctamnete';
                    } else {
                        $create = DB::table('product')->where('id_product', $productoEntity->getIdProducto())->update($productoEntity->Update());
                        DB::table('product_por_lotes')->where('id_product', $productoEntity->getIdProducto())->delete();
                        $idProducto = $productoEntity->getIdProducto();
                        $message = 'Producto actualizado correctamnete';
                    }
                    foreach ($lote as $l) {
                        DB::table('product_por_lotes')->insertGetId([
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
                    $exepcion = new Exepciones(true, $message, 200, []);
                    return $exepcion->SendStatus();
                case 0:
                    DB::beginTransaction();
                    if ($productoEntity->getIdProducto() === 0) {
                        $create = DB::table('product')->insertGetId($productoEntity->Create());
                        $code = DB::select("SELECT concat('P', (LPAD($create, 4, '0'))) as codigo");
                        DB::table('product')->where('id_product', $create)->update(['pro_code'=>$code[0]->codigo]);
                        $productoEntity->setIdProducto($create);
                        DB::table('product_por_unidades')->insert($productoEntity->CreateProductUnidades());
                        $message = 'Producto registrado';
                    } else {
                        DB::table('product')->where('id_product', $productoEntity->getIdProducto())->update($productoEntity->Update());
                        $idPorducto = $productoEntity->getIdProducto();
                        $productoEntity->setIdProducto($idPorducto);
                        DB::table('product_por_unidades')->where('id_product', $idPorducto)->update($productoEntity->CreateProductUnidades());
                        $message = 'Producto Actualizado';
                    }
                    DB::commit();
                    $exepcion = new Exepciones(true, $message, 200, []);
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
            $numeroRecnumXUnidad = $params['numeroRecnumXUnidad'];
            $cantidadRegistros = 20;
            $queryXLote = DB::table('product as pro');
            $queryXunidad = DB::table('product as pro');
            if ($params->idClase > 0) {
                $queryXLote->where('pro.id_clase_producto',$params->idClase);
                $queryXunidad->where('pro.id_clase_producto',$params->idClase);
            }
            if ($params->idUnidad > 0) {
                $queryXLote->where('pro.id_unidad_medida',$params->idUnidad);
                $queryXunidad->where('pro.id_unidad_medida',$params->idUnidad);
            }
            if ($params->desde && $params->hasta) {
                $queryXLote->whereBetween('pro.pro_fecha_creacion',[$params->desde, $params->hasta]);
                $queryXunidad->whereBetween('pro.pro_fecha_creacion',[$params->desde, $params->hasta]);
            }


            $queryXLote->join('product_por_lotes as pl', 'pl.id_product', '=', 'pro.id_product')
                  ->join('clase_producto as subclase', 'pro.id_subclase', 'subclase.id_clase_producto')
                  ->join('clase_producto as cp', 'pro.id_clase_producto', '=', 'cp.id_clase_producto')
                  ->join('unidad_medida as um', 'pro.id_unidad_medida', '=', 'um.id_unidad_medida')
                  ->select('pro.*', 'cp.clas_name as clasePadre', 'subclase.clas_name as classHijo', 'um.um_name as unidad')
                  ->skip($numeroRecnum)
                  ->take($cantidadRegistros)
                 ->distinct()
                  ->orderBy('pro.id_product', 'Asc')
                  ->get();
            $productoxlote= $queryXLote->get();
            $queryXunidad->join('clase_producto as subcla', 'pro.id_subclase', 'subcla.id_clase_producto')
                    ->join('clase_producto as clp', 'pro.id_clase_producto', '=', 'clp.id_clase_producto')
                    ->join('unidad_medida as ume', 'pro.id_unidad_medida', '=', 'ume.id_unidad_medida')
                    ->join('product_por_unidades as proun', 'proun.id_product', '=', 'pro.id_product')
                    ->select('pro.*', 'clp.clas_name as clasePadre', 'subcla.clas_name as classHijo', 'ume.um_name as unidad', 'proun.*')
                    ->skip($numeroRecnumXUnidad)
                    ->take($cantidadRegistros)
                    ->orderBy('pro.id_product', 'Asc')
                    ->get();
            $productoxUnidad= $queryXunidad->get();
            if (count($productoxlote) < $cantidadRegistros) {
                $numberRecnum = 0;
                $noMore = true;
            } else {
                $numberRecnum = (int)$numeroRecnum + count($productoxlote);
                $noMore = false;
            }
            if (count($productoxUnidad) < $cantidadRegistros) {
                $numberRecnumxunidad = 0;
                $noMorexunidad = true;
            } else {
                $numberRecnumxunidad = (int)$numeroRecnum + count($productoxUnidad);
                $noMorexunidad = false;
            }
            $excepcion = new Exepciones(true,'Productos Encontrados', 200,
                [   'productxlote'=>$productoxlote, 'productxUnidad' =>$productoxUnidad,
                    'numeroRecnum'=>$numberRecnum, 'noMore'=>$noMore,
                    'numeroRecnumXunidad'=>$numberRecnumxunidad, 'noMoreXUnidad'=>$noMorexunidad
                ]
            );
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
            $typeproduc = $params['typeProducto'];
            if ($idClase > 0 && $idProduct > 0) {
                $hijo = $this->Clasehijoxidpadre($idClase);
                $product = DB::table('product as p');
                if ($typeproduc === 'unidad') {
                    $product->join('product_por_unidades as proun', 'proun.id_product', '=', 'p.id_product')
                            ->select('p.*','proun.*','cp.clas_name as clasPadre', 'subclase.clas_name as classHijo', 'u.um_name');
                } else {
                    $product->select('p.*','cp.clas_name as clasPadre', 'subclase.clas_name as classHijo', 'u.um_name');
                }
                $product->join('clase_producto as cp', 'p.id_clase_producto', '=', 'cp.id_clase_producto')
                        ->join('clase_producto as subclase', 'p.id_subclase', 'subclase.id_clase_producto')
                        ->join('unidad_medida as u', 'p.id_unidad_medida', 'u.id_unidad_medida')
                        ->where('p.id_product', $idProduct);
                $producto = $product->first();
                $lote = DB::table('product_por_lotes')->where('id_product', $idProduct)->get();
                $exepcion= new Exepciones(true, 'Producto Encontrado', 200, ['clahijo'=>$hijo, 'product' => $producto, 'lote'=>$lote]);
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
            if ($item['lot_precio_compra'] === 0  || !$item['lot_precio_compra']) {
                $error = 'El precio de compra del lote '.$item['lot_name']. ' debe ser mayor a 0';
                array_push($detalleError, $error);
            }
            if ($item['lot_precio_venta'] === 0 || !$item['lot_precio_venta']) {
                $error = 'El precio de venta del lote '.$item['lot_name'].' debe ser mayor a 0';
                array_push($detalleError, $error);
            }
            if ($item['lot_cantidad'] === 0 || !$item['lot_cantidad']) {
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

    function search(string $params)
    {
        try {
            $search = DB::table('product')
                ->where('pro_name', 'like', '%'.$params.'%')
                ->orWhere('pro_code','like', '%'.$params.'%')
                ->where('pro_status', '=', 'active')
                ->get();
            $ecepciones = new Exepciones(true, 'Productos Encontradas', 200, $search);
            return $ecepciones->SendStatus();
        } catch (QueryException $exception) {
            $ecepciones = new Exepciones(false, $exception->getMessage(), $exception->getCode(), []);
            return $ecepciones->SendStatus();
        }
    }

    function selectProducto($params)
    {
        try {
            switch ($params['typeProducto']) {
                case 'lote':
                    $numeroRecnum = $params['numeroRecnum'];
                    $cantidadRegistros = 20;
                    $producto = DB::table('product')
                        ->skip($numeroRecnum)
                        ->take($cantidadRegistros)
                        ->distinct()
                        ->orderBy('id_product', 'Asc')
                        ->get();
                    if (count($producto) < $cantidadRegistros) {
                        $numberRecnum = 0;
                        $noMore = true;
                    } else {
                        $numberRecnum = (int)$numeroRecnum + count($producto);
                        $noMore = false;
                    }
                    $excepcion = new Exepciones(true,'Productos Encontrados', 200, ['producto'=>$producto, 'numeroRecnum'=>$numberRecnum, 'noMore'=>$noMore]);
                    return $excepcion->SendStatus();
                case 'unidad':
                    $numeroRecnum = $params['numeroRecnum'];
                    $cantidadRegistros = 20;
                    $producto = DB::table('product_por_unidades as pu')
                        ->join('product as p', 'pu.id_product', '=', 'p.id_product')
                        ->skip($numeroRecnum)
                        ->take($cantidadRegistros)
                        ->distinct()
                        ->orderBy('p.id_product', 'Asc')
                        ->get();
                    if (count($producto) < $cantidadRegistros) {
                        $numberRecnum = 0;
                        $noMore = true;
                    } else {
                        $numberRecnum = (int)$numeroRecnum + count($producto);
                        $noMore = false;
                    }
                    $excepcion = new Exepciones(true,'Productos Encontrados', 200, ['producto'=>$producto, 'numeroRecnum'=>$numberRecnum, 'noMore'=>$noMore]);
                    return $excepcion->SendStatus();
            }

        } catch (QueryException $exception) {
            $excepcion = new Exepciones(false,$exception->getMessage(), $exception->getCode(),[]);
            return $excepcion->SendStatus();
        }
    }
    function AjustarStock($params) {
        if (count($params['lote']) > 0) {
            $status =  $this->validarAjustarStock($params['lote']);
            if (count($status) > 0) {
                $excepciones = new Exepciones(false,'error', 401, ['error'=>$status]);
                return $excepciones->SendStatus();
            } else {
                foreach ($params['lote'] as $item) {
                    DB::table('product_por_lotes')->where('id_lote', $item['id_lote'])
                        ->update([
                            'lot_cantidad'=> $item['cantidad'],
                            'lot_creation_date' =>$item['lot_expiration_date']
                        ]);
                }
                $message = 'Lotes Ajustado Correctamente';
            }
        } else {
                DB::table('product_por_unidades')
                    ->where('id_product_unidades', $params['id_product_unidades'])
                    ->update([
                        'cantidad'=> $params['pro_cantdad'],
                        'fecha_vencimiento' =>$params['fecha_vencimiento']
                    ]);
                $message = 'Producto Ajustado Correctamente';
        }
        $excepciones = new Exepciones(true,$message, 200, ['error'=>[]]);
        return $excepciones->SendStatus();
    }
    function validarAjustarStock($params) {
        $detalleError = array();
        foreach ($params as $item) {
            if ($item['codigo_lote'] === '') {
                $error = 'Codigo del lote'.$item['codigo_lote']. ' es requerido';
                array_push($detalleError, $error);
            }
            if ($item['cantidad'] === 0 || !$item['cantidad']) {
                $error = 'El Lote '.$item['codigo_lote'].' tiene cantidad cero';
                array_push($detalleError, $error);
            }
            if ($item['lot_expiration_date'] === '') {
                $error = 'Fecha de vencimiento del lote '.$item['codigo_lote'].' es requerida';
                array_push($detalleError, $error);
            }
            if ($item['pro_nombre'] === '') {
                if ($item['codigo_lote'] === '') {
                    $error = 'El producto  es requerido';
                } else {
                    $error = 'El producto del '.$item['codigo_lote'].' es requerido';
                }
                array_push($detalleError, $error);
            }
        }
        return $detalleError;
    }
}
