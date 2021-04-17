<?php


namespace Core\CortesCaja\Infraestructura\DataBase;


use App\Http\Excepciones\Exepciones;
use Carbon\Carbon;
use Core\CortesCaja\Domain\Interfaces\CortesInterface;
use Core\Traits\QueryTraits;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;

class CorteSql implements CortesInterface
{
    use QueryTraits;
    function obtenerSaldoInicial(int $idCaja)
    {
        $fechahoy = Carbon::now('America/Lima')->format('Y-m-d');
        try {
            if ($idCaja === 0) {
                $messge = "EL numero de caja debe ser mayor a 0";
                $exepciones = new Exepciones(false,$messge,403,[]);
                return $exepciones->SendStatus();
            }
            $caja = DB::table('caja')->where('id_caja', $idCaja)->first();
            if (empty($caja->id_caja)) {
                $messge = "El numero de caja ingresado no existe en nuestra base de datos";
                $exepciones = new Exepciones(false,$messge,403,[]);
                return  $exepciones->SendStatus();
            }
            $saldoInicial = DB::table('caja_historial')->where('ch_tipo_operacion', '=', 'apertura')
                ->where(DB::raw('DATE(ch_fecha_operacion)'), $fechahoy )
                ->select(DB::raw('IFNULL(sum(ch_total_dinero), 0) as saldoInicial'))
                ->get();
            $messge = "monto Inicial encontrado";
            $exepciones = new Exepciones(true,$messge,200,$saldoInicial);
            return  $exepciones->SendStatus();
        } catch (QueryException $exception) {
            $exepciones = new Exepciones(false,$exception->getMessage(),$exception->getCode(),[]);
            return  $exepciones->SendStatus();
        }


    }

    function GuardarCorte($detalleCorteCaja, $corteCaja)
    {
        DB::beginTransaction();
        try {
            $idCorteCaja = DB::table('caja_corte')->insertGetId([
                'fecha_corte' => $corteCaja['fecha'],
                'hora_inicio' =>$corteCaja['horaInicio'],
                'hora_termino' =>$corteCaja['horaTermino'],
                'id_caja' =>$corteCaja['idCaja'],
                'monto_inicial' =>$corteCaja['saldoInicio'],
                'ganancias_x_dia'=>$corteCaja['totalCobrado'],
                'total_monedas'=> $corteCaja['totalMonedas'],
                'total_billetes' =>$corteCaja['totalBilletes']
            ]);
            DB::table('caja_corte_diario')->insertGetId([
                'fecha_corte_diario' =>$corteCaja['fecha'],
                'id_caja_corte' => $idCorteCaja,
                'monto_entregado_dia' =>$corteCaja['totalEntregado'],
            ]);
            if ($detalleCorteCaja['corteSemanal']) {
                DB::table('caja_corte_semanal')->insert([
                    'id_caja' =>$corteCaja['idCaja'],
                    'ccs_monto_ingresado' =>$corteCaja['totalEntregarSemanal'],
                    'ccs_fecha_corte' =>$corteCaja['fecha'],
                    'css_fecha_inicio' =>$detalleCorteCaja['fechaInicio'],
                    'css_fecha_termino' =>$detalleCorteCaja['fechaTermino']
                ]);
                $message = 'EL corte caja semanal numero '.$idCorteCaja. ' se guardo correctamente';
            } else {
                $message = 'EL corte caja diario numero '.$idCorteCaja. ' se guardo correctamente';
            }
            $billetes = $detalleCorteCaja['billetes'];
            $monedas = $detalleCorteCaja['monedas'];
            for ($i = 0; $i < sizeof($billetes); $i++) {
                DB::table('detalle_corte_caja')->insert([
                    'dcc_cantidad' => $billetes[$i]['cantidad'],
                    'dcc_total' => $billetes[$i]['subtotal'],
                    'dcc_valor' =>$billetes[$i]['descripcion'],
                    'id_corte_caja' =>$idCorteCaja,
                    'dcc_type_money' =>$billetes[$i]['type_money']
                ]);
            }
            for ($i = 0; $i < sizeof($monedas); $i++) {
                DB::table('detalle_corte_caja')
                    ->insert([
                        'dcc_cantidad' => $monedas[$i]['cantidad'],
                        'dcc_total' => $monedas[$i]['subtotal'],
                        'dcc_valor' =>$monedas[$i]['descripcion'],
                        'id_corte_caja' =>$idCorteCaja,
                        'dcc_type_money' =>$monedas[$i]['type_money']
                    ]);
            }
            DB::commit();
            $excepciones = new Exepciones(true,$message,200, []);
            return $excepciones->SendStatus();
        }catch (QueryException $exception){
            DB::rollBack();
            $excepcion = new Exepciones(false, $exception->getMessage(), $exception->getCode(), []);
            return $excepcion->SendStatus();
        }
    }

    function buscarCortesXFechas($fechaDesde, $fechaHasta, $idCaja)
    {
        try {
            $query = DB::table('detalle_corte_caja as dt')
                ->join('caja_corte as cc', 'dt.id_corte_caja','=', 'cc.id_caja_corte')
                ->select('dt.*', 'cc.fecha_corte')
                ->whereBetween('cc.fecha_corte', [$fechaDesde, $fechaHasta])
                ->get();
            $excepciones = new Exepciones(true,'lista encontrada', 200, $query);
            return $excepciones->SendStatus();
        }catch (QueryException $exception) {
            $excepciones = new Exepciones(false, $exception->getMessage(), $exception->getCode(), []);
            return $excepciones->SendStatus();
        }
    }

    function totales(int $idPersona, int $idcaja, $fechaDesde, $fechaHasta)
    {
        // TODO: Implement totales() method.
    }

    function obtenerTotalesCorte($fechaDesde, $fechaHasta, $idUsuario, $idCaja)
    {
        $fechaDesdeFormat = Carbon::make($fechaDesde)->format('Y-m-d');
        $fechaHastaFormat = Carbon::make($fechaHasta)->format('Y-m-d');
        try {
            if ($idCaja <= 0) {
                $exepciones = new Exepciones(false,'El numero caja debe ser mayor a 0',403,[]);
                return $exepciones->SendStatus();
            }

            if ($idUsuario <= 0) {
                $exepciones = new Exepciones(false,'El numero usuario debe ser mayor a 0',403,[]);
                return $exepciones->SendStatus();
            }
            $validUsuario = $this->ValidarCajaXusuario($idCaja, $idUsuario);// valido si el usuario pertenece a la caja
            if ($validUsuario) {
               $query = DB::table('caja_corte_diario as cd')
                    ->join('caja_corte as c', 'cd.id_caja_corte', '=', 'c.id_caja_corte')
                    ->where('c.id_caja', $idCaja)
                    ->whereBetween('fecha_corte', [$fechaDesdeFormat, $fechaHastaFormat])
                    ->select('c.total_monedas','c.fecha_corte', 'c.total_billetes', 'c.ganancias_x_dia', 'cd.monto_entregado_dia', 'cd.id_caja_corte')
                    ->get();
                $message = 'totales de la semana encontrados';
                $exepciones = new Exepciones(200,$message,200,$query);
                return  $exepciones->SendStatus();
            }
            $message = 'la caja numero ' . $idCaja. ' no te pertenece';
            $exepciones = new Exepciones(false,$message,403,[]);
            return  $exepciones->SendStatus();
        }catch (QueryException $exception) {
            $exepciones = new Exepciones(false,$exception->getMessage(),$exception->getCode(),[]);
            return $exepciones->SendStatus();
        }
    }
}
