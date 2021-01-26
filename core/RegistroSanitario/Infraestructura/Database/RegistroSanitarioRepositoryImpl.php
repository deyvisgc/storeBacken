<?php


namespace Core\RegistroSanitario\Infraestructura\Database;


use Core\RegistroSanitario\Domain\Entity\RegistroSanitarioEntity;
use Core\RegistroSanitario\Domain\Repositories\RegistroSanitarioRepository;
use Core\RegistroSanitario\Domain\ValueObjects\IdRegistroSanitario;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;

class RegistroSanitarioRepositoryImpl implements RegistroSanitarioRepository
{

    public function crearRegistroSanitario(RegistroSanitarioEntity $registroSanitarioEntity)
    {
        try {
            $create = DB::table('registro_sanitario')->insert([
                'rs_codigo' => $registroSanitarioEntity->getCodigo(),
                'rs_fecha_vencimiento' => $registroSanitarioEntity->getFechaVencimiento(),
                'rs_descripcion' => $registroSanitarioEntity->getDescription()
            ]);
            if ($create === true) {
                return response()->json(['status' => true, 'code' => 200, 'message' => 'Registro sanitario creado']);
            } else {
                return response()->json(['status' => false, 'code' => 400, 'message' => 'Registro sanitario no creado']);
            }
        }   catch
            (QueryException $exception){
                return $exception->getMessage();
            }
    }

    public function updateRegistroSanitario(RegistroSanitarioEntity $registroSanitarioEntity)
    {
        try {
            return $edit = DB::table('registro_sanitario')
                ->where('id_registro_sanitario', $registroSanitarioEntity->getIdRegistroSanitario())
                ->update([
                    'rs_codigo' => $registroSanitarioEntity->getCodigo(),
                    'rs_fecha_vencimiento' => $registroSanitarioEntity->getFechaVencimiento(),
                    'rs_descripcion' => $registroSanitarioEntity->getDescription()
                ]);
        }catch (QueryException $exception){
             return $exception->getMessage();
        }
    }

    public function deleteRegistroSanitario(int $idRegistroSanitario)
    {
        try {
            return DB::table('registro_sanitario')
                ->where('id_registro_sanitario','=',$idRegistroSanitario)
                ->delete();
        }catch (QueryException $exception){
            return $exception->getMessage();
        }

    }

    public function listarRegistroSanitario()
    {
        try {
            return DB::table('registro_sanitario')->get();
        } catch (QueryException $exception){
            return $exception->getMessage();
        }
    }
}
