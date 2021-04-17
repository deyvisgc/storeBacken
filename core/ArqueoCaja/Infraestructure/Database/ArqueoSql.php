<?php


namespace Core\ArqueoCaja\Infraestructure\Database;



use App\Http\Excepciones\Exepciones;
use Carbon\Carbon;
use Core\ArqueoCaja\Domain\Entity\ArqueoEntity;
use Core\ArqueoCaja\Domain\Interfaces\ArqueoCajaRepository;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;

class ArqueoSql implements ArqueoCajaRepository
{

    function CreateArqueo(ArqueoEntity $entity)
    {
        try {
            $idArqueo =   DB::table('arqueo_caja')->insertGetId($entity->Create());
            $message = 'El arqueo numero '.$idArqueo.' se guardo correctamente';
            $excepciones = new Exepciones(true, $message, 200, []);
            return $excepciones->SendStatus();
        }catch (QueryException $exception) {
            $excepciones = new Exepciones(false, $exception->getMessage(), $exception->getCode(), []);
            return $excepciones->SendStatus();
        }
    }

    function ListArqueo()
    {
        // TODO: Implement ListArqueo() method.
    }

    function ObtenerTotales($params)
    {
        try {
            $idCaja = $params['idCaja'];
            $fechDesde = $params['fechaDesde'];
            $fechHasta = $params['fechaHasta'];
            if ($idCaja <= 0) {
                $message = 'La caja numero '.$idCaja. 'debe ser mayor a 0';
                $excepciones = new Exepciones(false, $message, 401, []);
                return $excepciones->SendStatus();
            }
            $id = DB::table('caja')->where('id_caja', $idCaja)->first();
            if (empty($id->id_caja)) {
                $message = 'La caja numero '.$idCaja. 'no existe en nuestro sistema';
                $excepciones = new Exepciones(false, $message, 401, []);
                return $excepciones->SendStatus();
            }
            if ($fechDesde && !$fechHasta) {
                $data =  $this->CorteDiario($idCaja, $fechDesde);
                if (is_array($data)) {
                    $excepciones = new Exepciones(true, 'totales Encontrados', 200,$data);
                    return $excepciones->SendStatus();
                }
                $excepciones = new Exepciones(false, $data, 401,[]);
                return $excepciones->SendStatus();
            } else {
                $data =  $this->CorteSemanal($idCaja, $fechDesde,$fechHasta);
                if (is_array($data)) {
                    $excepciones = new Exepciones(true, 'totales Encontrados', 200,$data);
                    return $excepciones->SendStatus();
                }
                $excepciones = new Exepciones(false, $data, 401,[]);
                return $excepciones->SendStatus();
            }
        }catch (QueryException $exception) {
            $excepciones = new Exepciones(false, $exception->getMessage(), $exception->getCode(), []);
            return $excepciones->SendStatus();
        }
    }
 function CorteDiario($idCaja,$fecha) {
     $Corte = DB::table('caja_corte_diario as cd')
         ->join('caja_corte as c', 'cd.id_caja_corte', '=', 'c.id_caja_corte')
         ->where('c.id_caja', $idCaja)
         ->where('c.fecha_corte', '=', $fecha)
         ->select(DB::raw('IFNULL(cd.monto_entregado_dia, 0) as totalEntregado'),
                  DB::raw( 'IFNULL(c.total_monedas, 0) as monedas'),
                  DB::raw('IFNULL(c.total_billetes, 0) as billetes'),
                  DB::raw('IFNULL(c.monto_inicial, 0) as montoApertura')
         )->first();
     $totalVenta = DB::table('caja_historial')
         ->select(DB::raw('IFNULL(sum(ch_total_dinero), 0) as totalVenta'))
         ->where('ch_tipo_operacion', '=', 'ingreso')
         ->where(DB::raw('date(ch_fecha_operacion)'), $fecha)
         ->first();

     if (empty($Corte)) {
         $message = 'La fecha '.$fecha. ' no concuerda con la fecha de corte de caja';
         return $message;
     }

     if ($totalVenta->totalVenta == 0) {
         $message = 'La fecha '.$fecha. ' no concuerdan con las fechas de la venta del dia';
         return $message;
     }
     return array('Corte'=>$Corte, 'venta' =>$totalVenta);
 }
 function CorteSemanal($idCaja, $fechadesde, $fechaHasta) {
     $Corte = DB::table('caja_corte_diario as cd')
         ->join('caja_corte as c', 'cd.id_caja_corte', '=', 'c.id_caja_corte')
         ->where('c.id_caja', $idCaja)
         ->whereBetween('c.fecha_corte', [$fechadesde, $fechaHasta])
         ->select(
             DB::raw('IFNULL(sum(c.total_monedas), 0) as monedas'),
             DB::raw('IFNULL(sum(c.total_billetes), 0) as billetes'),
             DB::raw('IFNULL(sum(c.monto_inicial), 0) as montoApertura'),
             DB::raw('IFNULL(sum(cd.monto_entregado_dia), 0) as totalEntregado')
         )
         ->first();
     $totalVenta = DB::table('caja_historial')
         ->select(DB::raw('IFNULL(sum(ch_total_dinero), 0) as totalVenta'))
         ->where('ch_tipo_operacion', '=', 'ingreso')
         ->where('id_caja', $idCaja)
         ->whereBetween(DB::raw('date(ch_fecha_operacion)'), [$fechadesde, $fechaHasta])
         ->first();
     if ((float)$Corte->monedas == 0 || (float)$Corte->billetes == 0 || (float)$Corte->montoApertura == 0 && (float)$Corte->totalEntregado == 0) {
         $message = 'Las fechas '.$fechadesde.' '. $fechaHasta. ' no concuerda con la fecha de corte de caja';
         return $message;
     }
     if ($totalVenta->totalVenta == 0) {
         $message = 'Las fecha '.$fechadesde.' '.$fechaHasta . ' no concuerdan con las fechas de la venta de la semana';
         return $message;
     }
     return array('Corte'=>$Corte, 'venta' =>$totalVenta);
 }

}
