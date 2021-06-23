<?php


namespace Core\Producto\Infraestructure\AdapterBridge;


use Core\Producto\Aplication\UseCases\CreateCase;
use Core\Producto\Infraestructure\DataBase\ProductoSql;
use Illuminate\Http\Request;

class CreateBridge
{


    public function __construct(ProductoSql $productoSql)
    {
        $this->productoSql = $productoSql;
    }
    public function __invoke($params)
    {
        $id_producto = $params['id_producto'];
        $pro_nombre=$params['pro_nombre'];
        $pro_descripcion=$params['descripcion'];
        $pro_cod_barra=$params['codigo_barra'];
        $id_clase_producto=$params['id_clase'];
        $id_sub_clase=$params['id_sub_clase'];
        $id_unidad_medida=$params['id_unidad'];
        $fecha=$params['fecha_creacion'];
        $lote=$params['lote'];
        $precio_compra = $params['precio_compra'];
        $precio_ventra =$params['precio_venta'];
        $cantidad = $params['cantidad'];
        $createProducto= new CreateCase($this->productoSql);
      return  $createProducto->__invoke($id_producto, $pro_nombre,$pro_descripcion, $pro_cod_barra,$id_clase_producto, $id_sub_clase, $id_unidad_medida, $lote, $fecha, $precio_compra, $precio_ventra, $cantidad);
    }
}
