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
            $fecha = Carbon::make($params['fecha'])->format('Y-m-d');
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
            $Corte = DB::table('caja_corte as c')
                           ->where('c.id_caja', $idCaja)
                           ->where('c.fecha_corte', '=', $fecha)
                           ->first();
            $totalVenta = DB::table('caja_historial')
                ->select(DB::raw('IFNULL(sum(ch_total_dinero), 0) as total'))
                ->where('ch_tipo_operacion', '=', 'ingreso')
                ->where(DB::raw('date(ch_fecha_operacion)'), $fecha)
                ->get();
            $totalCorte = DB::table('caja_corte_diario')
                          ->select('monto_entregado_dia')
                          ->where(DB::raw('date(fecha_corte_diario)'), $fecha)
                          ->where('id_caja_corte', $Corte->id_caja_corte)
                          ->first();
            if (empty($Corte)) {
                $message = 'La fecha '.$fecha. ' no concuerda con la fecha de corte de caja';
                $excepciones = new Exepciones(false, $message, 401,[]);
                return $excepciones->SendStatus();
            }
            if ($totalVenta[0]->total == 0) {
                $message = 'La fecha '.$fecha. ' no concuerda con la fecha del historial de caja';
                $excepciones = new Exepciones(false, $message, 401,[]);
                return $excepciones->SendStatus();
            }
            if (empty($totalCorte)) {
                $message = 'La fecha '.$fecha. ' no concuerda con la fecha del corte de caja';
                $excepciones = new Exepciones(false, $message, 401,[]);
                return $excepciones->SendStatus();
            }
            $excepciones = new Exepciones(true, 'totales Encontrados', 200,
                                          array('totalVenta' => $totalVenta[0]->total, 'Corte' =>$Corte, 'totalCorte'=>$totalCorte->monto_entregado_dia));
            return $excepciones->SendStatus();
        }catch (QueryException $exception) {
            $excepciones = new Exepciones(false, $exception->getMessage(), $exception->getCode(), []);
            return $excepciones->SendStatus();
        }
    }
}
