<?php


namespace Core\Almacen\Lote\Infraestructure\DataBase;


use Core\Almacen\Lote\Domain\Entity\LoteEntity;
use Core\Almacen\Lote\Domain\Repositories\LoteRepository;
use Illuminate\Support\Facades\DB;

class LoteSql implements LoteRepository
{
    function Create(LoteEntity $loteEntity)
    {
        $lote = DB::table('lote')->insert([
            'lot_name' => $loteEntity->Lotname()->getLotname(),
            'lot_status' => 'active',
            'lot_codigo' => $loteEntity->Lotcodigo()->getLotcodigo(),
            'lot_expiration_date' => $loteEntity->Loteespiradate()->getExpridatedate(),
            'lot_creation_date' => $loteEntity->LotCreationDate()->getLotecreadate()
        ]);
        if ($lote == true) {
            return ['status' => true, 'message' => 'Lote Registrado Correctamente'];
        }
        return ['status' => false, 'message' => 'Error al Registrar Este lote'];
    }

    function Update(LoteEntity $loteEntity, int $id)
    {
        $lote = DB::table('lote')->where('id_lote', $id)
            ->update([
                'lot_name' => $loteEntity->Lotname()->getLotname(),
                'lot_codigo' => $loteEntity->Lotcodigo()->getLotcodigo(),
                'lot_expiration_date' => $loteEntity->Loteespiradate()->getExpridatedate(),
                'lot_creation_date' => $loteEntity->LotCreationDate()->getLotecreadate()]);
        if ($lote == 1) {
            return ['status' => true, 'message' => 'Lote Actualizado Correctamente'];
        }
        return ['status' => false, 'message' => 'Error al Actualizar Este lote'];
    }

    function Read()
    {
        return DB::table('lote')->get();
    }

    function Readxid(int $id)
    {
        // TODO: Implement Readxid() method.
    }

    function delete(int $id)
    {
        if ($id > 0) {
            $lote = DB::table('lote')->where('id_lote', $id)->delete();
            if ($lote == 1) {
                return ['status' => true, 'message' => 'Lote Eliminado Correctamente'];
            }
            return ['status' => false, 'message' => 'Error al Eliminar Este lote'];
        } else {
            return ['status' => true, 'message' => 'Lote no existe en esta base de datos'];
        }
    }

    function CambiarStatus(int $id, string $status)
    {

        try {
            if ($status === 'active') {
                $status = 'disable';
            } else {
                $status = 'active';
            }
            $query = DB::table('lote')->where('id_lote',$id)->update(['lot_status'=>$status]);
            if ($query === 1) {
                return ['status'=>true, 'message'=>'Cambio de estado exitoso'];
            } else {
                return ['status'=>false, 'message'=>'Error al  Cambiar el estado'];
            }
        }catch (\Exception $exception) {
            return $exception->getMessage();
        }
    }
}
