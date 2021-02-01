<?php


namespace Core\Sangria\Infraestructura\AdapterBridge;


use Core\Sangria\Application\UseCases\EditSangriaUseCase;
use Core\Sangria\Domain\Entity\SangriaEntity;
use Core\Sangria\Infraestructura\DataBase\SangriaRepositoryImpl;

class EditSangriaAdapter
{
    private SangriaRepositoryImpl $sangriaRepositoryImpl;

    public function __construct(SangriaRepositoryImpl $sangriaRepositoryImpl)
    {
        $this->sangriaRepositoryImpl = $sangriaRepositoryImpl;
    }
    public function editSangria(SangriaEntity $sangriaEntity){
        $editSangria = new EditSangriaUseCase($this->sangriaRepositoryImpl);
        return $editSangria->editSangria($sangriaEntity);
    }
}
