<?php


namespace Core\Compras\Infraestructure\Sql;


use App\Http\Excepciones\Exepciones;
use Core\Compras\Domain\ComprasRepository;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;

class ReadRepository implements ComprasRepository
{

    public function Read(object $data)
    {

        try {
            switch ($data['default']) {
                case '1':
                    $status =  DB::table('compra as com')
                        ->join('persona as per', 'com.idProveedor', '=', 'per.id_persona')
                        ->select('com.*', 'per.per_razon_social as razonSocial', 'per.per_ruc as ruc')
                        ->where('comTipoPago', 'credito')
                        ->get();
                    $excepciones = new  Exepciones(true,'listaEncontrada',200,$status);
                    return $excepciones->SendError();
                case '2':
                    break;
            }
        }catch (QueryException $exception) {
            $excepciones = new  Exepciones(false,'error',$exception->getCode(),$exception->getMessage());
            return $excepciones->SendError();
        }
    }

    public function Detalle(int $id)
    {
        try {
            $status = DB::table('detalle_compra as dtc')
                      ->join('compra as c','dtc.idCompra', '=', 'c.idCompra')
                      ->join('product as pr','dtc.idProduct', '=', 'pr.id_product')
                      ->where('dtc.idCompra', '=', $id)
                      ->select('dtc.*','pr.pro_name')
                       ->get();
            $excepciones = new  Exepciones(true,'listaEncontrada',200,$status);
            return $excepciones->SendError();
        }catch (QueryException $exception) {
            $excepciones = new  Exepciones(false,'error',$exception->getCode(),$exception->getMessage());
            return $excepciones->SendError();
        }
    }
}
