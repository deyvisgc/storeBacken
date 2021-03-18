<?php


namespace Core\Traits;


use Illuminate\Support\Facades\DB;

trait CarritoTraits
{
    public function searchProveedorandCliente (string  $documento) {
        switch (strlen($documento)) {
            case 8 :
                $datacliente = DB::table('persona as per')
                    ->join('type_identidad as type','per.id_type_identidad','=', 'type.id_type_identidad')
                    ->where('type.dni','=',$documento)
                    ->select('per.*','type.*')
                    ->get();
                return $datacliente;
            case  11 :
                $dataproveedor = DB::table('persona as per')
                    ->join('type_identidad as type','per.id_type_identidad','=', 'type.id_type_identidad')
                    ->where('type.ruc','=',$documento)
                    ->select('per.*','type.*')
                    ->get();
                return $dataproveedor;
        }
    }
    public function searchProveedor () {
        $dataproveedor = DB::table('persona as per')
            ->whereNotNull('per.per_ruc')
            ->where('per.per_status' , '=', 'active')
            ->get();
        return $dataproveedor;
    }
    public function Addcarrito($request) {
        $cantidad = $request['pro_cantidad'];
        $precio_compra = $request['precio_compra'];
        $idProducto = $request['idProducto'];
        $idPersona = $request['idPersona'];
        $idCaja = $request['idCaja'];
        $status = DB::select("CALL addCarrCompra (?,?,?,?,?)", array($cantidad,$precio_compra,$idProducto,$idPersona,$idCaja));
        return $status;

    }
    public function Listar(int $id) {
        $lista = DB::select("select car.id,car.idProducto,car.idPersona,car.idCaja,car.cantidad,car.precio,car.subTotal, pro.pro_name, per.per_razon_social,totales.total
                                 from ((select sum(carrito.subTotal) as total from carrito where idPersona = $id)) totales,
                                 carrito as car, product as pro, persona as per where
                                 car.idProducto= pro.id_product and
                                 car.idPersona = per.id_persona and
                                 car.idPersona = $id group by car.id,car.idProducto,car.idPersona,car.idCaja,car.cantidad,car.precio, car.subTotal,totales.total,pro.pro_name, per.per_razon_social");
        return  ['status'=>true, 'lista' => $lista];
        /* $lista =  DB::table('carrito as car')
              ->join('product as pro', 'car.idProducto', '=','pro.id_product')
              ->join('persona as per', 'car.idPersona', '=', 'per.id_persona')
              ->where('car.idPersona', $id)
              ->select('car.','per.per_razon_social', DB::raw('SUM(car.subTotal) as total'))
              ->get()
              ->groupBy('per.per_razon_social');
        return $lista;
        */
    }
    public function ActualizarCantidad ($request) {
        if (!$request['value']) {
            return  ['status'=>false , 'message'=> 'Requiere una cantidad mayor a 0 para hacer la operacion'];
        } else {
            $subtotal = (float) $request['value'] * $request['precio'];
            DB::table('carrito')->where('id', $request['id'])->update(['cantidad'=> $request['value'], 'subTotal' =>$subtotal]);
            return $this->Listar($request['idPersona']);
        }
    }
    public function DeleteCarr($request) {
        $id = $request['id'];
        if ($id > 0) {
            DB::table('carrito')->where('id', $request['id'])->delete();
            return $this->Listar($request['idPersona']);
        } else {
            return  ['status'=>false , 'message'=> 'La columna'.$id. 'no se encuentra en nuestra base de datos'];
        }
    }
    public function PagarCompra($array) {
        return $array[0];
    }
}
