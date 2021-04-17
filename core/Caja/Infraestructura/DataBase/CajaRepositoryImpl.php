<?php


namespace Core\Caja\Infraestructura\DataBase;


use App\Http\Excepciones\Exepciones;
use Carbon\Carbon;
use Core\Caja\Domain\Entity\CajaEntity;
use Core\Caja\Domain\Repositories\CajaRepository;
use Core\Traits\QueryTraits;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class CajaRepositoryImpl implements CajaRepository
{
    use QueryTraits;
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
    function totales(int $idUsuario, $idCaja, $fechaDesde, $fechaHasta)
    {
        try {
            $status = $this->ValidarCajaXusuario($idCaja, $idUsuario);
            if ($status) {
                if (!$fechaDesde && !$fechaHasta) {
                    $fechaHoy  = Carbon::now('America/Lima')->format('Y-m-d');
                    $data = $this->SearchNowDate($idCaja,$fechaHoy);
                    $message = 'GRAFICO DE TOTALES DEL DIA: '.$fechaHoy;
                } else {
                    $fechaDesdeFormat  = Carbon::make($fechaDesde)->format('Y-m-d');
                    $fechaHataFormat   = Carbon::make($fechaHasta)->format('Y-m-d');
                    $message = 'GRAFICO DE TOTALES DEL DIA: '. $fechaDesdeFormat.' HASTA '. $fechaHataFormat;
                    $data = $this->SearchXRangeDate($idCaja, $fechaDesdeFormat, $fechaHataFormat);
                }
                $exepciones = new Exepciones(true, $message, 200, [$data][0]);
                return $exepciones->SendStatus();
            }
            $exepciones = new Exepciones(false, 'Usted no tiene permiso para ver esta caja', 403,[]);
            return $exepciones->SendStatus();
        } catch (QueryException $exception) {
            $exepciones = new Exepciones(false, $exception->getMessage(),$exception->getCode() , []);
           return $exepciones->SendStatus();
        }
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
                         'id_user' => $request['caja']['idUser'],
                         'id_caja' => $request['caja']['idCaja'],
                         'ch_total_dinero' => $request['caja']['montoApertura']
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
}
