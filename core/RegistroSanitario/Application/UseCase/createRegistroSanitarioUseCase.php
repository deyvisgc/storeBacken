<?php


namespace Core\RegistroSanitario\Application\UseCase;


use Core\RegistroSanitario\Domain\Entity\RegistroSanitarioEntity;
use Core\RegistroSanitario\Domain\Repositories\RegistroSanitarioRepository;

class createRegistroSanitarioUseCase
{

    /**
     * @var RegistroSanitarioRepository
     */
    private RegistroSanitarioRepository $registroSanitarioRepository;

    public function __construct(RegistroSanitarioRepository $registroSanitarioRepository)
    {
        $this->registroSanitarioRepository = $registroSanitarioRepository;
    }
    public function createRegistro (RegistroSanitarioEntity $registroSanitarioEntity){
        return $this->registroSanitarioRepository->crearRegistroSanitario($registroSanitarioEntity);
    }
}
