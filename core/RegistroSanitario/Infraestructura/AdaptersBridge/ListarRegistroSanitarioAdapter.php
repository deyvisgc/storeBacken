<?php


namespace Core\RegistroSanitario\Infraestructura\AdaptersBridge;


use Core\RegistroSanitario\Application\UseCase\listarRegistroSanitarioUseCase;
use Core\RegistroSanitario\Infraestructura\Database\RegistroSanitarioRepositoryImpl;

class ListarRegistroSanitarioAdapter
{
    /**
     * @var RegistroSanitarioRepositoryImpl
     */
    private RegistroSanitarioRepositoryImpl $registroSanitarioRepositoryImpl;

    public function __construct(RegistroSanitarioRepositoryImpl $registroSanitarioRepositoryImpl)
    {
        $this->registroSanitarioRepositoryImpl =$registroSanitarioRepositoryImpl;
    }
    public function listRegistroSanitario()
    {
        $listRegistroSanitario = new listarRegistroSanitarioUseCase($this->registroSanitarioRepositoryImpl);
        return $listRegistroSanitario->listRegistroSanitario();
    }

}
