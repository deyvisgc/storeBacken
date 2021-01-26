<?php


namespace Core\RegistroSanitario\Infraestructura\AdaptersBridge;


use Core\RegistroSanitario\Domain\Repositories\RegistroSanitarioRepository;

class DeleteRegistroSanitarioAdapter
{
    private RegistroSanitarioRepository $registroSanitarioRepository;
    public function __construct(RegistroSanitarioRepository $registroSanitarioRepository)
    {
        $this->registroSanitarioRepository = $registroSanitarioRepository;
    }
    public function deleteRegistro($idRegistroSanitario){
        return $this->registroSanitarioRepository->deleteRegistroSanitario($idRegistroSanitario);
    }
}
