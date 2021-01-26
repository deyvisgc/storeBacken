<?php


namespace Core\RegistroSanitario\Infraestructura\AdaptersBridge;


use Core\RegistroSanitario\Application\UseCase\updateRegistroSanitarioUseCase;
use Core\RegistroSanitario\Domain\Entity\RegistroSanitarioEntity;
use Core\RegistroSanitario\Infraestructura\Database\RegistroSanitarioRepositoryImpl;

class UpdateRegistroSanitarioAdapter
{
    private RegistroSanitarioRepositoryImpl $registroSanitarioRepositoryImpl;

    public function __construct(RegistroSanitarioRepositoryImpl $registroSanitarioRepositoryImpl)
    {
        $this->registroSanitarioRepositoryImpl= $registroSanitarioRepositoryImpl;
    }
    public function updateRegistro(RegistroSanitarioEntity $registroSanitarioEntity)
    {
        $updateRegistro = new updateRegistroSanitarioUseCase($this->registroSanitarioRepositoryImpl);
        return $updateRegistro->updateRegistro($registroSanitarioEntity);
    }
}
