<?php


namespace Core\RegistroSanitario\Domain\Repositories;


use Core\RegistroSanitario\Domain\Entity\RegistroSanitarioEntity;
use Core\RegistroSanitario\Domain\ValueObjects\IdRegistroSanitario;

interface RegistroSanitarioRepository
{
    public function crearRegistroSanitario(RegistroSanitarioEntity $registroSanitarioEntity);
    public function updateRegistroSanitario(RegistroSanitarioEntity $registroSanitarioEntity);
    public function deleteRegistroSanitario(IdRegistroSanitario $idRegistroSanitario);
    public function listarRegistroSanitario();
}
