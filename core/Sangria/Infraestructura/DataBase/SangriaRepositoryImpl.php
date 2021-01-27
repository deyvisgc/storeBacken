<?php


namespace Core\Sangria\Infraestructura\DataBase;


use Core\Sangria\Domain\Entity\SangriaEntity;
use Core\Sangria\Domain\Repositories\SagriaRepository;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;

class SangriaRepositoryImpl implements SagriaRepository
{
    public function listSangria()
    {
        try {
            return DB::table('sangria')
                ->get();
        }catch (QueryException $exception){
            return $exception->getMessage();
        }
    }

    public function editSangria(SangriaEntity $sangriaEntity)
    {
        try {
            return $edit = DB::table('sangria')
                ->where('id_sangria',$sangriaEntity->getIdSangria())
                ->update([
                    'san_monto' =>$sangriaEntity->getSanMonto(),
                    'san_fecha'=>$sangriaEntity->getSanFecha(),
                    'san_tipo_sangria'=>$sangriaEntity->getSanTipo(),
                    'san_motivo'=>$sangriaEntity->getSanMotivo(),
                    'id_caja'=>$sangriaEntity->getIdCaja(),
                    'id_user'=>$sangriaEntity->getIdUser()
                ]);
            if ($edit ===true){
                return response()->json(['status' => true, 'code' => 200, 'message' => 'Sangria editada']);
            } else{
                return response()->json(['status' => false, 'code' => 400, 'message' => 'Sangria no editada']);
            }
        }catch (QueryException $exception){
            return $exception->getMessage();
        }
    }

    public function createSangria(SangriaEntity $sangriaEntity)
    {
        try {
            $create = DB::table('sangria')
                ->insert([
                    'san_monto' =>$sangriaEntity->getSanMonto(),
                    'san_fecha'=>$sangriaEntity->getSanFecha(),
                    'san_tipo_sangria'=>$sangriaEntity->getSanTipo(),
                    'san_motivo'=>$sangriaEntity->getSanMotivo(),
                    'id_caja'=>$sangriaEntity->getIdCaja(),
                    'id_user'=>$sangriaEntity->getIdUser()
                ]);
            if ($create ===true){
                return response()->json(['status' => true, 'code' => 200, 'message' => 'Sangria creada']);
            } else{
                return response()->json(['status' => false, 'code' => 400, 'message' => 'Sangria no creada']);
            }
        }catch (QueryException $exception){
            return $exception->getMessage();
        }
    }

    public function deleteSangria($idSangria)
    {
        try {
            return DB::table('sangria')
                ->where('id_sangria','=', $idSangria)
                ->delete();
        }catch (QueryException $exception){
            return $exception->getMessage();
        }
    }
}
