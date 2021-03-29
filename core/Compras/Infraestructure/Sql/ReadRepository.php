<?php


namespace Core\Compras\Infraestructure\Sql;


use App\Http\Excepciones\Exepciones;
use App\Models\compras;
use Core\Compras\Domain\ComprasRepository;
use Core\Traits\QueryTraits;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Input;
use Illuminate\Support\Facades\Log;

class ReadRepository implements ComprasRepository
{
    use QueryTraits;

    public function Read(object $data)
    {
        try {
            $table =  $data['tabla'];
            Log::info($data['fechaDesde']);
            $query =  DB::table('compra as com');
            if($data['tabla'] && $data['tabla'] !== 'vigente' && $data['tabla'] !== 'anuladas') {
                $query->where('comTipoPago', $data['tabla']);
            }
            if($data['tabla'] === 'anuladas') {
                $query->where('comEstado', 0);
            }
            if ($data['fechaDesde'] && $data['fechaHasta']) {
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
            $status = $this->ReadCompraxid($id);
            $excepciones = new  Exepciones(true,'listaEncontrada',200,$status);
            return $excepciones->SendError();
        }catch (QueryException $exception) {
            $excepciones = new  Exepciones(false,'error',$exception->getCode(),$exception->getMessage());
            return $excepciones->SendError();
        }
    }

    public function UpdateStatus(int $id)
    {
        try {
            $status = DB::table('compra')->where('idCompra', $id)->first();
            if (empty($status->idCompra)) {
                $message = 'No existe la compra'.$id. 'en nuestro sistema';
                $excepciones = new  Exepciones(false,$message,400,$status);
                return $excepciones->SendError();
            }
            $estado = $status->comEstado === 1 ? 0 : 1;
            DB::table('compra')->where('idCompra', $id)->update(['comEstado' => $estado]);
            $message = 'La compra numero '.$status->comSerieCorrelativo. ' fue anulada correctamente';
            $excepciones = new  Exepciones(true,$message,200,$status);
            return $excepciones->SendError();
        }catch (QueryException $exception) {
            $excepciones = new  Exepciones(false,$exception->getMessage(),$exception->getCode(),0);
            return $excepciones->SendError();
        }
    }
}
