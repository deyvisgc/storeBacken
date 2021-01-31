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
    public function __invoke(Request $request)
    {
        $pro_nombre=$request->data['pro_nombre'];
        $pro_precio_compra=$request->data['pro_precio_compra'];
        $pro_precio_venta=$request->data['pro_precio_venta'];

        $pro_cantidad=$request->data['cantidad'];
        $pro_cantidad_min=$request->data['cantidad_minima'];
        $pro_description=$request->data['descripcion'];
        $id_lote=$request->data['lote'];
        $id_clase_producto=$request->data['clase'];
        $id_unidad_medida=$request->data['unidad'];
        $pro_cod_barra=$request->data['codigo_barra'];
        $pro_code=$request->data['codigo'];
        $createProducto= new CreateCase($this->productoSql);
      return  $createProducto->__invoke($pro_nombre, $pro_precio_compra, $pro_precio_venta, $pro_cantidad, $pro_cantidad_min, $pro_description, $id_lote, $id_clase_producto, $id_unidad_medida, $pro_cod_barra, $pro_code);
    }
}
