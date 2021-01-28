<?php


namespace Core\RegistroSanitario\Domain\Repositories;


use Core\RegistroSanitario\Domain\Entity\RegistroSanitarioEntity;

interface RegistroSanitarioRepository
{
    public function crearRegistroSanitario(RegistroSanitarioEntity $registroSanitarioEntity);
    public function updateRegistroSanitario(RegistroSanitarioEntity $registroSanitarioEntity);
    public function deleteRegistroSanitario(int $idRegistroSanitario);
    public function listarRegistroSanitario();
}
