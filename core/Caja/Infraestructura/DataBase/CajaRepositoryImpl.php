<?php


namespace Core\Caja\Infraestructura\DataBase;


use Core\Caja\Domain\Entity\CajaEntity;
use Core\Caja\Domain\Repositories\CajaRepository;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;

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


}
