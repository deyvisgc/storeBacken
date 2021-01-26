<?php


namespace Core\RegistroSanitario\Application\UseCase;


use Core\RegistroSanitario\Domain\Entity\RegistroSanitarioEntity;
use Core\RegistroSanitario\Domain\Repositories\RegistroSanitarioRepository;

class updateRegistroSanitarioUseCase
{
private RegistroSanitarioRepository $registroSanitarioRepository;

public function __construct( RegistroSanitarioRepository $registroSanitarioRepository)
{
    $this->registroSanitarioRepository = $registroSanitarioRepository;
}
public function updateRegistro(RegistroSanitarioEntity $registroSanitarioEntity){
    return $this->registroSanitarioRepository->updateRegistroSanitario($registroSanitarioEntity);
}
}
