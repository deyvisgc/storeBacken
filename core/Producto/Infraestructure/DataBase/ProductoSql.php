<?php


namespace Core\Producto\Infraestructure\DataBase;


use Core\Producto\Domain\Entity\ProductoEntity;
use Core\Producto\Domain\Repositories\ProductoRepository;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;

class ProductoSql implements ProductoRepository
{

    function Create(ProductoEntity $productoEntity)
    {
        try {
            $create = DB::table('product')
                ->insert(
                    ['pro_name' => $productoEntity->Nombre()->getProNombre(),
                        'pro_precio_compra' => $productoEntity->PrecioCompra()->getProPrecioCompra(),
                        'pro_precio_venta' => $productoEntity->PrecioVenta()->getProPrecioVenta(),
                        'pro_cantidad' => $productoEntity->Cantidad()->getProCantidad(),
                        'pro_cantidad_min' => $productoEntity->CantidadMinima()->getProCantidadMinima(),
                        'pro_status' => '1',
                        'pro_description' => $productoEntity->Descripcion()->getProDescripcion(),
                        'id_lote' => $productoEntity->IDLOTE()->getIdlote(),
                        'id_clase_producto' => $productoEntity->IDClaseProducto()->getIdclaseProducto(),
                        'id_unidad_medida' => $productoEntity->UnidadMedida()->getIdunidadmedida(),
                        'pro_cod_barra' => $productoEntity->Barra()->getBarra(),
                        'pro_code' => $productoEntity->Code()->getCode()
                    ]);
            if ($create == true) {
                return ['status' => true, 'message' => 'Registro existo'];
            } else {
                return ['status' => false, 'message' => 'Error al registrar'];
            }
        } catch (\Exception $exception) {
            return $exception->getMessage();
        }

    }

    function Update(ProductoEntity $productoEntity, int $idproducto)
    {
        try {
            if ($idproducto > 0) {
                DB::table('product')->where('id_product', $idproducto)->update([
                    'pro_name' => $productoEntity->Nombre()->getProNombre(),
                    'pro_precio_compra' => $productoEntity->PrecioCompra()->getProPrecioCompra(),
                    'pro_precio_venta' => $productoEntity->PrecioVenta()->getProPrecioVenta(),
                    'pro_cantidad' => $productoEntity->Cantidad()->getProCantidad(),
                    'pro_cantidad_min' => $productoEntity->CantidadMinima()->getProCantidadMinima(),
                    'pro_description' => $productoEntity->Descripcion()->getProDescripcion(),
                    'id_lote' => $productoEntity->IDLOTE()->getIdlote(),
                    'id_clase_producto' => $productoEntity->IDClaseProducto()->getIdclaseProducto(),
                    'id_unidad_medida' => $productoEntity->UnidadMedida()->getIdunidadmedida(),
                    'pro_cod_barra' => $productoEntity->Barra()->getBarra(),
                    'pro_code' => $productoEntity->Code()->getCode()
                ]);
                return ['status' => true, 'message' => 'Actualizado Correctamente'];
            } else {
                return ['status' => false, 'message' => 'Error al Actualizar'];
            }
        } catch (\Exception $exception) {
            return $exception->getMessage();
        }
    }

    function Read()
    {
        return DB::table('product as pro')
            ->join('lote as l', 'pro.id_lote', '=', 'l.id_lote')
            ->join('clase_producto as cp', 'pro.id_clase_producto', '=', 'cp.id_clase_producto')
            ->join('unidad_medida as um', 'pro.id_unidad_medida', '=', 'um.id_unidad_medida')
            ->select('pro.*', 'cp.clas_name as clase', 'l.lot_name as lote', 'um.um_name as unidad')
            ->orderBy('id_product', 'Asc')
            ->get();
    }

    function Readxid(int $id)
    {
        if ($id > 0) {
            $produc = DB::table('product')->where('id_product', $id)->first();
            $lote = DB::table('lote')->get();
            $clase = DB::table('clase_producto')->get();
            $unidad = DB::table('unidad_medida')->get();
            return array('producto' => $produc, 'lote' => $lote, 'clase' => $clase, 'unidad' => $unidad);
        } else {
            return ['status' => false, 'message' => 'id inexistente'];
        }

    }

    function delete(int $idproducto)
    {
        if ($idproducto > 0) {
            DB::table('product')->where('id_product', $idproducto)->delete();
            return ['status' => true, 'message' => 'Elimiando Correctamente'];
        } else {
            return ['status' => false, 'message' => 'Error al Eliminar'];
        }
    }

    function CambiarStatus(string $status, int $id)
    {
        if ($id > 0) {
            if ($status === '0') {
                $status = '1';
            } else {
                $status = '0';
            }
            DB::table('product')->where('id_product', $id)->update(['pro_status'=>$status]);
            return ['status' => true, 'message' => 'Estado  Actualizado Correctamente'];
        } else {
            return ['status' => false, 'message' => 'Error al cambiar de estado'];
        }
    }
}
