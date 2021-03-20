<?php


namespace Core\Traits;


use Illuminate\Support\Facades\App;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\URL;

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
    public function PagarCompra($data) {
        $subtotal = (double)$data->subtotal;
        $total = (double)$data->total;
        $igv = (double) $data->igv;
        $tipoComprobante = $data->tipoComprobante;
        $tipoPago = $data->tipoPago;
        $idPersona = $data->idProveedor;
        $status = DB::select("CALL addCompra (?,?,?,?,?,?)", array($subtotal, $total, $igv, "'$tipoComprobante'", "' $tipoPago'",$idPersona));
        if ($status[0]->idCompra > 0) {
            $fileExtension = $data->file('pdf')->getClientOriginalName();
            $file = pathinfo($fileExtension, PATHINFO_FILENAME);
            $extension = $data->file('pdf')->getClientOriginalExtension();
            $fileStore = $file . '_' . time() . '.' . $extension;
            $path = $data->file('pdf')->storeAs('Comprobantes', $fileStore);
           /* $url = Storage::disk('local')->path($path); */
            $url = URL::asset('storage/app/'.$path);
            DB::table('compra')->where('id_compra', $status[0]->idCompra)->update(['url_comprobante'=>$path]);

            return ['status'=> true, 'message' => 'La compra numero '.$status[0]->idCompra.' se realizo correctamente'];
        }
         return ['status'=> false, 'message' => 'Error al realizar la compra'];;
    }
}
