<?php


namespace Core\RegistroSanitario\Infraestructura\AdaptersBridge;


use Core\RegistroSanitario\Domain\Repositories\RegistroSanitarioRepository;

class CreateRegistroSanitarioAdapter
{

    /**
     * @var RegistroSanitarioRepository
     */
    private RegistroSanitarioRepository $registroSanitarioRepository;

    public function __construct(RegistroSanitarioRepository $registroSanitarioRepository)
    {
        $this->registroSanitarioRepository = $registroSanitarioRepository;
    }
}
