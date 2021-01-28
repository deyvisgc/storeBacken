<?php


namespace Core\HistorialCaja\Infraestructura\DataBase;


use Core\HistorialCaja\Domain\Entity\HistorialCajaEntity;
use Core\HistorialCaja\Domain\Repositories\HistorialCajaRepository;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;
use function PHPUnit\Framework\exactly;

class HistorialCajaRepositoryImpl implements HistorialCajaRepository
{

    public function listHistorialCaja()
    {
        try {
            return DB::table('caja_historial')
                ->get();
        }catch (QueryException $exception){
            return $exception->getMessage();
        }
    }

    public function editHistorialCaja(HistorialCajaEntity $historialCajaEntity)
    {
        try {
            return $edit =DB::table('caja_historial')
                ->where('id_caja_historial', $historialCajaEntity->getIdCajaHistory())
                ->update([
                    'ch_fecha_operacion'=>$historialCajaEntity->getChDate(),
                    'ch_tipo_operacion'=>$historialCajaEntity->getChTypeOperation(),
                    'ch_total_dinero'=>$historialCajaEntity->getChTotal(),
                    'id_user'=>$historialCajaEntity->getIdUser(),
                    'id_caja'=>$historialCajaEntity->getIdCaja()
                ]);
            if ($edit === true) {
                return response()->json(['status' => true, 'code' => 200, 'message' => 'Caja editada']);
            } else {
                return response()->json(['status' => false, 'code' => 400, 'message' => 'Caja no editada']);
            }
        }catch (QueryException $exception)
        {
            return $exception->getMessage();
        }
    }

    public function createHistorialCaja(HistorialCajaEntity $historialCajaEntity)
    {
        try {
            $create = DB::table('caja_historial')
                ->insert([
                    'ch_fecha_operacion'=>$historialCajaEntity->getChDate(),
                    'ch_tipo_operacion'=>$historialCajaEntity->getChTypeOperation(),
                    'ch_total_dinero'=>$historialCajaEntity->getChTotal(),
                    'id_user'=>$historialCajaEntity->getIdUser(),
                    'id_caja'=>$historialCajaEntity->getIdCaja()
                ]);
            if ($create === true) {
                return response()->json(['status' => true, 'code' => 200, 'message' => 'Historial de caja creada']);
            } else {
                return response()->json(['status' => false, 'code' => 400, 'message' => 'Historial de caja no creada']);
            }
        }catch (QueryException $exception){
            return $exception->getMessage();
        }
    }

    public function deleteHistorialCaja(int $idCajaHistory)
    {
        try {
            return DB::table('caja_historial')
                ->where('id_caja_historial','=', $idCajaHistory)
                ->delete();
        }catch (QueryException $exception){
            return $exception->getMessage();
        }
    }
}
