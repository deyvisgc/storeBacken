<?php


namespace Core\RegistroSanitario\Application\UseCase;


use Core\RegistroSanitario\Domain\Repositories\RegistroSanitarioRepository;

class deleteRegistroSanitarioUseCase
{
    private RegistroSanitarioRepository $registroSanitarioRepository;

    public function __construct(RegistroSanitarioRepository $registroSanitarioRepository)
    {
        $this->registroSanitarioRepository= $registroSanitarioRepository;
    }
    Public function deleteRegistro($idRegistroSanitario){
        return $this->registroSanitarioRepository->deleteRegistroSanitario($idRegistroSanitario);
    }
}

