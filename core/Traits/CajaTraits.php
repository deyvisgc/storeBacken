<?php


namespace Core\Traits;


use Carbon\Carbon;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;

trait CajaTraits
{
    function ActualizarMontoCaja ($idCaja, $idUser, $monto,$fecha, $tipo) {
        try {
            $date = Carbon::parse($fecha)->format('Y-m-d');
            $query = DB::table('caja as c')
                ->where
                ([['c.ca_status' , '=', 'open'], ['c.id_caja' , '=', $idCaja], [DB::raw('DATE(c.ca_fecha_creacion)') , '=', $date],
                ])->first();
            if (empty($query)){
                return [false, 'Necesita abrir caja para hacer esta operacion'];
            } else {
             $status =   DB::table('caja_historial')->insert([
                 'ch_tipo_operacion' =>$tipo,
                 'ch_fecha_operacion' =>$fecha,
                 'ch_total_dinero' =>$monto,
                 'id_user' =>$idUser,
                 'id_caja' =>$idCaja,
                 'ch_monto_tipo_operacion' =>$monto
                ]);
                return [$status, 'exito'];
            }
        }catch (QueryException $exception) {
            return  [false, $exception->getMessage()];
        }
    }
}
