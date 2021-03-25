<?php


namespace Core\Compras\Infraestructure\Sql;


use App\Http\Excepciones\Exepciones;
use App\Models\compras;
use Core\Compras\Domain\ComprasRepository;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Input;

class ReadRepository implements ComprasRepository
{

    public function Read(object $data)
    {

        try {
            $query =  DB::table('compra as com');

            if($data['tabla'] === 'credito') {
                $query->where('comTipoPago',$data['tabla']);
            }
            if ($data['fechaDesde'] !== '' && $data['fechaHasta'] !== '') {
                $query->whereBetween('comFecha', [$data['fechaDesde'], $data['fechaHasta']]);
            }
            if ($data['codeProveedor']) {
                $query->where('idProveedor',$data['codeProveedor']);
            }
            if ($data['tipoPago']) {
                $query->where('comTipoPago',$data['tipoPago']);
            }
            if ($data['tipoComprobante']) {
                $query->where('comTipoComprobante',$data['tipoComprobante']);
            }
            $query->join('persona as per', 'com.idProveedor', '=', 'per.id_persona')
                    ->select('com.*', 'per.per_razon_social as razonSocial', 'per.per_ruc as ruc');
            $result= $query->get();
            $excepciones = new  Exepciones(true,'listaEncontrada',200, $result);
            return $excepciones->SendError();
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

    public function Filtros($params)
    {
        return $params;

    }
}
