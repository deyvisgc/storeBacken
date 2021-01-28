<?php


namespace Core\Sangria\Infraestructura\AdapterBridge;


use Core\Sangria\Application\UseCases\ListSangriaUseCase;
use Core\Sangria\Infraestructura\DataBase\SangriaRepositoryImpl;

class ListSangriaAdapter
{
    private SangriaRepositoryImpl $sangriaRepositoryImpl;

    public function __construct(SangriaRepositoryImpl $sangriaRepositoryImpl)
    {
        $this->sangriaRepositoryImpl =$sangriaRepositoryImpl;
    }
    public function listSangria()
    {
        $listSangria= new ListSangriaUseCase($this->sangriaRepositoryImpl);
        return $listSangria->listSangria();
    }
}
