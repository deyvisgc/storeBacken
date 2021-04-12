<?php


namespace Core\Caja\Infraestructura\DataBase;


use App\Http\Excepciones\Exepciones;
use Carbon\Carbon;
use Core\Caja\Domain\Entity\CajaEntity;
use Core\Caja\Domain\Repositories\CajaRepository;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class CajaRepositoryImpl implements CajaRepository
{
    public function createCaja(CajaEntity $cajaEntity)
    {
        try {

            $create = DB::table('caja')->insert([
                'ca_name' => $cajaEntity->getCajaName(),
                'ca_description' => $cajaEntity->getCajaDescription(),
                'ca_status' => $cajaEntity->getCajaStatus(),
                'id_user' => $cajaEntity->getIdUser()
            ]);
            if ($create === true) {
                return response()->json(['status' => true, 'code' => 200, 'message' => 'Caja creada']);
            } else {
                return response()->json(['status' => false, 'code' => 400, 'message' => 'Caja no creada']);
            }
        }catch (QueryException $exception){
            return $exception->getMessage();
        }
    }

    public function updateCaja(CajaEntity $cajaEntity){
        try {
            return $edit = DB::table('caja')
                ->where('id_caja' , $cajaEntity->getIdCaja())
                ->update([
                    'ca_name'=>$cajaEntity->getCajaName(),
                    'ca_description'=>$cajaEntity->getCajaDescription(),
                    'ca_status'=>$cajaEntity->getCajaStatus(),
                    'id_user'=>$cajaEntity->getIdUser()
                ]);
        }catch (QueryException $exception){
            return $exception->getMessage();
        }
    }
    public function deleteCaja(int $idCaja){
        try {
            return DB::table('caja')
                ->where('id_caja','=',$idCaja)
                ->delete();
        }catch (QueryException $exception){
            return $exception->getMessage();
        }
    }
    public function listCaja(){
        try {
            return DB::table('caja')
                ->get();
        }catch (QueryException $exception){
            return $exception->getMessage();
        }
    }
    function totales(int $idPersona, $fechaDesde, $fechaHasta, $month, $year)
    {
        try {

            if ($fechaDesde && $fechaHasta) {
                $data = $this->queryXFECHAS($idPersona, $fechaDesde, $fechaHasta);
            }
         if ($month > 0) {
                $data = $this->queryXmonth($idPersona, $month);
            }
            if ($year > 0) {
                $data = $this->queryXYear($idPersona, $year);
            }
            $exepciones = new Exepciones(true, 'econtrados', 200,
                [$data['ingreso'][0], $data['salida'][0], $data['devoluciones'][0],$data['montoInicial'][0]]);
           return $exepciones->SendStatus();

        } catch (QueryException $exception) {
            $exepciones = new Exepciones(false, $exception->getMessage(),$exception->getCode() , []);
           return $exepciones->SendStatus();
        }
    }
    function queryXFECHAS ($idpersona,$fechaDesde, $fechaHasta) {
        $ingresos =  DB::table('caja_historial as ch')
                       ->join('caja as c', 'ch.id_caja', '=', 'c.id_caja')
                      ->select(DB::raw('IFNULL(SUM(ch.ch_monto_tipo_operacion), 0) as totalIngreso'))
                      ->where('ch.id_user', $idpersona)
                      ->where('c.ca_status', '=', 'open')
                      ->where('ch.ch_tipo_operacion', '=', 'ingreso')
                      ->whereBetween(DB::raw('DATE(ch.ch_fecha_operacion)'), [$fechaDesde , $fechaHasta])
                      ->get();
        $salidas =  DB::table('caja_historial as ch')
                      ->join('caja as c', 'ch.id_caja', '=', 'c.id_caja')
                      ->select(DB::raw('IFNULL(SUM(ch.ch_monto_tipo_operacion), 0) as totalSalidas'))
                      ->where('ch.id_user', $idpersona)
                      ->where('c.ca_status', '=', 'open')
                      ->where('ch.ch_tipo_operacion', '=', 'salida')
                      ->whereBetween(DB::raw('DATE(ch.ch_fecha_operacion)'), [$fechaDesde , $fechaHasta])
                      ->get();
        $devoluciones =  DB::table('caja_historial as ch')
                         ->join('caja as c', 'ch.id_caja', '=', 'c.id_caja')
                         ->select(DB::raw('IFNULL(SUM(ch.ch_monto_tipo_operacion), 0) as totalDevoluciones'))
                         ->where('c.ca_status', '=', 'open')
                         ->where('ch.id_user', $idpersona)
                         ->where('ch.ch_tipo_operacion', '=', 'devolucion')
                         ->whereBetween(DB::raw('DATE(ch.ch_fecha_operacion)'), [$fechaDesde , $fechaHasta])
                         ->get();
        $montoInicial =  DB::table('caja_historial as ch')
                         ->join('caja as c', 'ch.id_caja', '=', 'c.id_caja')
                        ->select(DB::raw('IFNULL(SUM(ch.ch_monto_tipo_operacion), 0) as montoInicial'))
                        ->where('c.ca_status', '=', 'open')
                        ->where('ch.id_user', $idpersona)
                        ->where('ch.ch_tipo_operacion', '=', 'apertura')
                        ->whereBetween(DB::raw('DATE(ch.ch_fecha_operacion)'), [$fechaDesde , $fechaHasta])
                        ->get();
        return array('ingreso'=> $ingresos, 'salida'=>$salidas, 'devoluciones'=>$devoluciones,
            'montoInicial' =>$montoInicial);
    }
    function queryXmonth ($idpersona,$month) {
        $ingresos =  DB::table('caja_historial as ch')
            ->join('caja as c', 'ch.id_caja', '=', 'c.id_caja')
            ->select(DB::raw('IFNULL(SUM(ch.ch_monto_tipo_operacion), 0) as totalIngreso'))
            ->where('ch.id_user', $idpersona)
            ->where('c.ca_status', '=', 'open')
            ->where('ch.ch_tipo_operacion', '=', 'ingreso')
            ->whereMonth('ch.ch_fecha_operacion', '=', $month)
            ->get();
        $salidas =  DB::table('caja_historial as ch')
            ->join('caja as c', 'ch.id_caja', '=', 'c.id_caja')
            ->select(DB::raw('IFNULL(SUM(ch.ch_monto_tipo_operacion), 0) as totalSalidas'))
            ->where('ch.id_user', $idpersona)
            ->where('c.ca_status', '=', 'open')
            ->where('ch.ch_tipo_operacion', '=', 'salida')
            ->whereMonth('ch.ch_fecha_operacion', '=', $month)
            ->get();
        $devoluciones =  DB::table('caja_historial as ch')
            ->join('caja as c', 'ch.id_caja', '=', 'c.id_caja')
            ->select(DB::raw('IFNULL(SUM(ch.ch_monto_tipo_operacion), 0) as totalDevoluciones'))
            ->where('ch.id_user', $idpersona)
            ->where('c.ca_status', '=', 'open')
            ->where('ch.ch_tipo_operacion', '=', 'devolucion')
            ->whereMonth('ch.ch_fecha_operacion', '=', $month)
            ->get();
        $montoInicial =  DB::table('caja_historial as ch')
            ->join('caja as c', 'ch.id_caja', '=', 'c.id_caja')
            ->select(DB::raw('IFNULL(SUM(ch.ch_monto_tipo_operacion), 0) as montoInicial'))
            ->where('ch.id_user', $idpersona)
            ->where('c.ca_status', '=', 'open')
            ->where('ch.ch_tipo_operacion', '=', 'apertura')
            ->whereMonth('ch.ch_fecha_operacion', '=', $month)
            ->get();
        return array('ingreso'=> $ingresos, 'salida'=>$salidas, 'devoluciones'=>$devoluciones,
            'montoInicial' =>$montoInicial);
    }
    function queryXYear ($idpersona,$year) {
        $ingresos =  DB::table('caja_historial as ch')
            ->join('caja as c', 'ch.id_caja', '=', 'c.id_caja')
            ->select(DB::raw('IFNULL(SUM(ch.ch_monto_tipo_operacion), 0) as totalIngreso'))
            ->where('ch.id_user', $idpersona)
            ->where('c.ca_status', '=', 'open')
            ->where('ch.ch_tipo_operacion', '=', 'ingreso')
            ->whereYear('ch.ch_fecha_operacion', '=', $year)
            ->get();
        $salidas =  DB::table('caja_historial as ch')
            ->join('caja as c', 'ch.id_caja', '=', 'c.id_caja')
            ->select(DB::raw('IFNULL(SUM(ch.ch_monto_tipo_operacion), 0) as totalSalidas'))
            ->where('ch.id_user', $idpersona)
            ->where('c.ca_status', '=', 'open')
            ->where('ch.ch_tipo_operacion', '=', 'salida')
            ->whereYear('ch.ch_fecha_operacion', '=', $year)
            ->get();
        $devoluciones =  DB::table('caja_historial as ch')
            ->join('caja as c', 'ch.id_caja', '=', 'c.id_caja')
            ->select(DB::raw('IFNULL(SUM(ch.ch_monto_tipo_operacion), 0) as totalDevoluciones'))
            ->where('ch.id_user', $idpersona)
            ->where('c.ca_status', '=', 'open')
            ->where('ch.ch_tipo_operacion', '=', 'devolucion')
            ->whereYear('ch.ch_fecha_operacion', '=', $year)
            ->get();
        $montoInicial =  DB::table('caja_historial as ch')
            ->join('caja as c', 'ch.id_caja', '=', 'c.id_caja')
            ->select(DB::raw('IFNULL(SUM(ch.ch_monto_tipo_operacion), 0) as montoInicial'))
            ->where('ch.id_user', $idpersona)
            ->where('c.ca_status', '=', 'open')
            ->where('ch.ch_tipo_operacion', '=', 'apertura')
            ->whereYear('ch.ch_fecha_operacion', '=', $year)
            ->get();
        return array('ingreso'=> $ingresos, 'salida'=>$salidas, 'devoluciones'=>$devoluciones,
            'montoInicial' =>$montoInicial);
    }
    public function aperturarCaja($request)
    {
        $fechaApertura = Carbon::now('America/Lima')->format('Y-m-d H:i');
        DB::beginTransaction();
        try {
            DB::table('caja')->where('id_caja', $request['caja']['idCaja'])
                 ->update(['ca_status' => $request['caja']['status']]);
            DB::table('caja_historial')->insertGetId([
                         'ch_fecha_operacion' =>$fechaApertura,
                         'ch_tipo_operacion' => 'apertura',
                         'ch_total_dinero' => 0,
                         'id_user' => $request['caja']['idUser'],
                         'id_caja' => $request['caja']['idCaja'],
                         'ch_monto_tipo_operacion' => $request['caja']['montoApertura']
                     ]);
          DB::commit();
          $messaje = "Exito al abrir caja numero ". $request['caja']['idCaja'];
          $exepciones = new Exepciones(true,$messaje,200,[]);
         return $exepciones->SendStatus();
        }catch (QueryException $exception) {
            DB::rollBack();
            $exepciones = new Exepciones(true,$exception->getMessage(),$exception->getCode(),[]);
          return  $exepciones->SendStatus();
        }
    }

    public function cerrarCaja($caja)
    {
        try {
             DB::table('caja')->where('id_caja', $caja['idCaja'])->update(['ca_status' => 'close']);
            $message = 'Caja numero '.$caja['idCaja'].'cerrada correctamente';
            $exception = new Exepciones(true, $message,200,[]);
            $exception->SendStatus();
        }catch (QueryException $exception) {
            $exception = new Exepciones(false, $exception->getMessage(), $exception->getCode(),[]);
            $exception->SendStatus();
        }
    }

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
                ->select(DB::raw('IFNULL(sum(ch_monto_tipo_operacion), 0) as saldoInicial'))
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

    function buscarCortesXFechas($fechaDesde, $fechaHasta)
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
}
