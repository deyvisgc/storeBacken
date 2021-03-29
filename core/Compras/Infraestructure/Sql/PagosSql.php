<?php


namespace Core\Compras\Infraestructure\Sql;


use App\Http\Excepciones\Exepciones;
use Carbon\Carbon;
use Core\Compras\Domain\PagosRepository;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;

class PagosSql implements PagosRepository
{

    public function PagosCredito($data)
    {
        $fecha = Carbon::now('America/Lima');
        try {
             $status= DB::table('historial_pagos_credito')->insert([
                'montoPagado' =>$data['monto'],
                 'montoDeuda' =>$data['deuda'],
                 'fechaCreacion' => $fecha,
                 'idVendedor' =>$data['idVendedor'],
                  'idCompra' =>$data['idCompra'],
                  'deudaPorPagar' => (float)$data['deudaporPagar']
                ]);
             if ($status) {
                 $compra = DB::table('compra')->where('idCompra', $data['idCompra'])->first();
                 if ((float)$data['deudaporPagar'] === (float)0) {
                     $estado = 2;
                 } else {
                     $estado = 1;
                 }
                 DB::table('compra')->where('idCompra', $data['idCompra'])->update(
                     [
                         'comMontoDeuda' =>  (float)$data['deudaporPagar'],
                         'comMontoPagado' => $compra->comMontoPagado+$data['monto'],
                         'comEstadoTipoPago' => $estado
                     ]);
               $exception = new Exepciones($status,'Pago de deuda completada',200,0);
              return $exception->SendError();
             }
        }catch (QueryException $exception) {
            $exception = new Exepciones(false,$exception->getMessage(),$exception->getCode(),0);
           return $exception->SendError();
        }
    }
}
