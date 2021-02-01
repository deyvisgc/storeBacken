<?php


namespace Core\RegistroSanitario\Infraestructura\AdaptersBridge;


use Core\RegistroSanitario\Application\UseCase\deleteRegistroSanitarioUseCase;
use Core\RegistroSanitario\Domain\Repositories\RegistroSanitarioRepository;
use Core\RegistroSanitario\Infraestructura\Database\RegistroSanitarioRepositoryImpl;

class DeleteRegistroSanitarioAdapter
{
    private RegistroSanitarioRepositoryImpl $registroSanitarioRepositoryImpl;

    public function __construct(RegistroSanitarioRepositoryImpl $registroSanitarioRepositoryImpl)
    {
        $this->registroSanitarioRepositoryImpl = $registroSanitarioRepositoryImpl;
    }
    public function deleteRegistro($idRegistroSanitario){
        $deleteRegistro = new deleteRegistroSanitarioUseCase($this->registroSanitarioRepositoryImpl);
        return $deleteRegistro->deleteRegistro($idRegistroSanitario);
    }
}
