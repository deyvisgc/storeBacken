<?php


namespace App\Repository\Almacen\Productos;


use App\Http\Excepciones\Exepciones;
use Carbon\Carbon;
use Core\Traits\QueryTraits;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;
const Code = '775820300317';
class ProductoRepository implements ProductoRepositoryInterface
{

     use QueryTraits;
    public function all($params)
    {
        try {
            $fechaDesde = Carbon::make($params->desde)->format('Y-m-d');
            $fechaHasta = Carbon::make($params->hasta)->format('Y-m-d');
            $lista = $this->ObtenerProductos($params->idClase, $params->idUnidad, $fechaDesde, $fechaHasta, $params->fechaVencimiento);
            $excepcion = new Exepciones(true,'Productos Encontrados', 200, $lista);
            return $excepcion->SendStatus();
        } catch (\Exception $exception) {
            $excepcion = new Exepciones(false,$exception->getMessage(), $exception->getCode(),[]);
            return $excepcion->SendStatus();
        }
    }

    public function create($params)
    {

        try {
            $id_producto = $params['id_producto'];
            $pro_nombre=$params['pro_nombre'];
            $pro_descripcion=$params['pro_descripcion'];
            $pro_cod_barra=$params['pro_codigo_barra'];
            $pro_marca=$params['pro_marca'];
            $pro_modelo=$params['pro_modelo'];
            $pro_fecha_vencimiento=$params['pro_fecha_vencimiento'];
            $unidad=$params['id_unidad'];
            $clase=$params['id_clase'];
            $sub_clase=$params['id_sub_clase'];
            $pro_precio_compra=$params['pro_precio_compra'];
            $pro_precio_venta=$params['pro_precio_venta'];
            $pro_stock_inicial=$params['pro_stock_inicial'];
            $pro_stock_minimo=$params['pro_stock_minimo'];
            $tipo_afectacion=$params['tipo_afectacion'];
            $almacen=$params['almacen'];
            $lote=$params['id_lote'] === 0 ? null : $params['id_lote'];
            $impuesto_igv=$params['impuesto_igv'];
            $moneda=$params['moneda'];
            $impuesto_bolsa=$params['impuesto_bolsa'];

            $producto = new dtoProducto($id_producto, $pro_nombre, $pro_descripcion, $pro_cod_barra, $pro_marca, $pro_modelo, $pro_fecha_vencimiento, $unidad, $clase, $sub_clase, $pro_precio_compra,
                $pro_precio_venta, $pro_stock_inicial, $pro_stock_minimo, $tipo_afectacion, $almacen,$lote, $impuesto_igv, $moneda, $impuesto_bolsa);
            if ($producto->getIdProducto() === 0) {
                $create = DB::table('product')->insertGetId($producto->Create());
                $code = DB::select("SELECT concat('P', (LPAD($create, 4, '0'))) as codigo");
                DB::table('product')->where('id_product', $create)->update(['pro_code'=>$code[0]->codigo]);
                $message = 'Producto registrado';
            } else {
                DB::table('product')->where('id_product', $producto->getIdProducto())->update($producto->Update());
                $message = 'Producto Actualizado';
            }
            $exepcion = new Exepciones(true, $message, 200, []);
            return $exepcion->SendStatus();
        } catch (\Exception $exception) {
            $exepcion = new Exepciones(false, $exception->getMessage(), $exception->getCode(), []);
            return $exepcion->SendStatus();
        }
    }

    public function update(array $data, $id)
    {
        // TODO: Implement update() method.
    }

    public function delete($idproducto)
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

    public function find($params)
    {
        // TODO: Implement find() method.
    }

    function getAtributos()
    {
        try {

            $almacen = DB::table('almacen')
                        ->orderBy('id', 'asc')
                        ->get();

            $tipoAfectacion = DB::table('tipo_afectacion')
                              ->where('tipo_afectacion', '=', 'igv')
                              ->orderBy('id', 'asc')
                              ->get();
            $exepcion = new Exepciones(true, '', 200, ['almacen'=>$almacen, 'tipoAfectacion' =>$tipoAfectacion]);
            return $exepcion->SendStatus();
        } catch (\Exception $exception) {
            $exepcion = new Exepciones(false, $exception->getMessage(), $exception->getCode(), []);
            return $exepcion->SendStatus();
        }

    }

    function generarCodigoBarra()
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

    public function show(int $id)
    {
        try {
           $sub_cate = $this->subCategoriaxID($id);
           $exepcion = new Exepciones(true, '', 200, $sub_cate);
           return $exepcion->SendStatus();
        } catch (\Exception $exception) {
            $exepcion = new Exepciones(false, $exception->getMessage(), $exception->getCode(), null);
            return $exepcion->SendStatus();
        }
    }

    function edit($id)
    {
       try {
            $producto = DB::table('product')->where('id_product', $id)->first();
            $unidad   = DB::table('unidad_medida')
                       ->where('id_unidad_medida', $producto->id_unidad_medida)->first();
            $clase    = DB::table('clase_producto')
                        ->where('id_clase_producto', $producto->id_clase_producto)->first();
            $subClase = DB::table('clase_producto')
                        ->where('id_clase_producto', $producto->id_subclase)->first();
            $lote     = DB::table('product_por_lotes')
                        ->where('id_lote', $producto->id_lote)->first();
            $almacen = DB::table('almacen')->get();
            $tipoAfectacion = DB::table('tipo_afectacion')->get();
            $exepcion = new Exepciones(true, '', 200, [
                'producto'=> $producto, 'unidad' =>$unidad, 'clase' =>$clase,
                'subClase'=>$subClase, 'lote'=>$lote, 'almacen'=>$almacen,
                'tipoAfectacion'=>$tipoAfectacion
            ]);
            return $exepcion->SendStatus();
        } catch (\Exception $exception) {
            $exepcion = new Exepciones(false, $exception->getMessage(), $exception->getCode(), null);
            return $exepcion->SendStatus();
        }
    }

    function changeStatus($data)
    {
        try {
            if ($data['id'] > 0) {
                if ($data['status'] === 'active') {
                    $status = 'disable';
                } else {
                    $status = 'active';
                }
               $statusUpdate = DB::table('product')->where('id_product', $data['id'])->update(['pro_status'=>$status]);
                if ($statusUpdate === 1) {
                    $excepcion= new Exepciones(true,'Estado  Actualizado Correctamente', 200, []);
                } else {
                    $excepcion= new Exepciones(false,'Error al cambiar de estado', 403, []);

                }
                return $excepcion->SendStatus();
            } else {
                $excepcion= new Exepciones(false,'Este producto no existe', 403, []);
                return $excepcion->SendStatus();
            }
        } catch (\Exception $exception) {
            $excepcion= new Exepciones(false,$exception->getMessage(), $exception->getCode(), []);
            return $excepcion->SendStatus();
        }
    }
}
