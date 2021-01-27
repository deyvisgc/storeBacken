<?php


namespace Core\Sangria\Infraestructura\AdapterBridge;


use Core\Sangria\Application\UseCases\DeleteSangriaUseCase;
use Core\Sangria\Infraestructura\DataBase\SangriaRepositoryImpl;

class DeleteSangriaAdapter
{
    private SangriaRepositoryImpl $sangriaRepositoryImpl;

    public function __construct(SangriaRepositoryImpl $sangriaRepositoryImpl)
    {
        $this->sangriaRepositoryImpl =$sangriaRepositoryImpl;
    }
    public function deleteSangria($idSangria){
        $deleteSangria = new DeleteSangriaUseCase($this->sangriaRepositoryImpl);
        return $deleteSangria->deleteSangria($idSangria);
    }
}
