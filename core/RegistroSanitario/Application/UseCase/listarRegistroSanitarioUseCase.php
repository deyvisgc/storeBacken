<?php


namespace Core\RegistroSanitario\Application\UseCase;


use Core\RegistroSanitario\Domain\Repositories\RegistroSanitarioRepository;

class listarRegistroSanitarioUseCase
{
    private RegistroSanitarioRepository $registroSanitarioRepository;

    public function __construct(RegistroSanitarioRepository $registroSanitarioRepository)
    {
        $this->registroSanitarioRepository=$registroSanitarioRepository;
    }
    public function listRegistroSanitario()
    {
        return $this->registroSanitarioRepository->listarRegistroSanitario();
    }

}
