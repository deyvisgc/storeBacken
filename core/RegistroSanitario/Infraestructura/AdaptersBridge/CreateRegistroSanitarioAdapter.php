<?php


namespace Core\RegistroSanitario\Infraestructura\AdaptersBridge;


use Core\RegistroSanitario\Application\UseCase\createRegistroSanitarioUseCase;
use Core\RegistroSanitario\Domain\Entity\RegistroSanitarioEntity;
use Core\RegistroSanitario\Infraestructura\Database\RegistroSanitarioRepositoryImpl;

class CreateRegistroSanitarioAdapter
{

    /**
     * @var RegistroSanitarioRepository
     */
    private RegistroSanitarioRepositoryImpl $registroSanitarioRepositoryImpl;

    public function __construct(RegistroSanitarioRepository $registroSanitarioRepositoryImpl)
    {
        $this->registroSanitarioRepositoryImpl = $registroSanitarioRepositoryImpl;
    }
    public function createRegistro(RegistroSanitarioEntity $registroSanitarioEntity){
        $createRegistro=new createRegistroSanitarioUseCase($this->registroSanitarioRepositoryImpl);
        return $createRegistro->createRegistro($registroSanitarioEntity);
    }
}
