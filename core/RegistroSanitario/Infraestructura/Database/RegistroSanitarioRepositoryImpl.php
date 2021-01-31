<?php


namespace Core\RegistroSanitario\Infraestructura\Database;


use Core\RegistroSanitario\Domain\Entity\RegistroSanitarioEntity;
use Core\RegistroSanitario\Domain\Repositories\RegistroSanitarioRepository;
use Core\RegistroSanitario\Domain\ValueObjects\ProCantidad;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;

class RegistroSanitarioRepositoryImpl implements RegistroSanitarioRepository
{

    public function crearRegistroSanitario(RegistroSanitarioEntity $registroSanitarioEntity)
    {
        // TODO: Implement crearRegistroSanitario() method.
    }

    public function updateRegistroSanitario(RegistroSanitarioEntity $registroSanitarioEntity)
    {
        // TODO: Implement updateRegistroSanitario() method.
    }

    public function deleteRegistroSanitario(int $idRegistroSanitario)
    {
        // TODO: Implement deleteRegistroSanitario() method.
    }

    public function listarRegistroSanitario()
    {
        try {
            return DB::table('registro_sanitario')->get();
        } catch (QueryException $exception){
            return $exception->getMessage();
        }
        // TODO: Implement listarRegistroSanitario() method.
    }
}
