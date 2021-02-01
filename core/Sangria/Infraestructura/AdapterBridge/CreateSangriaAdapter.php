<?php


namespace Core\Sangria\Infraestructura\AdapterBridge;


use Core\Sangria\Application\UseCases\CreateSangriaUseCase;
use Core\Sangria\Domain\Entity\SangriaEntity;
use Core\Sangria\Infraestructura\DataBase\SangriaRepositoryImpl;

class CreateSangriaAdapter
{
    private SangriaRepositoryImpl $sangriaRepositoryImpl;

    public function __construct(SangriaRepositoryImpl $sangriaRepositoryImpl)
    {
        $this->sangriaRepositoryImpl = $sangriaRepositoryImpl;
    }
    public function createSangria(SangriaEntity $sangriaEntity)
    {
        $createSangria = new CreateSangriaUseCase($this->sangriaRepositoryImpl);
        return $createSangria->createSangria($sangriaEntity);
    }
}
