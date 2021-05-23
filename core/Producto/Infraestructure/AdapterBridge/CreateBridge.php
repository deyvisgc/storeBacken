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
        $pro_nombre=$params['pro_nombre'];
        $pro_precio_compra=$params['pro_precio_compra'];
        $pro_precio_venta=$params['pro_precio_venta'];
        $pro_cantidad=$params['cantidad'];
        $pro_cantidad_min=$params['cantidad_minima'];
        $pro_description=$params['descripcion'];
        $pro_cod_barra=$params['codigo_barra'];
        $id_clase_producto=$params['clase'];
        $id_lote=$params['lote'];
        $id_sub_clase=$params['sub_clase'];
        $id_unidad_medida=$params['unidad'];
        $createProducto= new CreateCase($this->productoSql);
      return  $createProducto->__invoke($pro_nombre, $pro_precio_compra, $pro_precio_venta, $pro_cantidad, $pro_cantidad_min, $pro_description, $id_lote, $id_clase_producto, $id_unidad_medida, $pro_cod_barra,$id_sub_clase,$params);
    }
}
