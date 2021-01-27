<?php


namespace Core\Sangria\Application\UseCases;


use Core\Sangria\Domain\Entity\SangriaEntity;
use Core\Sangria\Domain\Repositories\SagriaRepository;

class CreateSangriaUseCase
{
    private SagriaRepository $sangriaRepository;

    public function __construct(SagriaRepository $sagriaRepository)
    {
        $this->sangriaRepository = $sagriaRepository;
    }
    public function createSangria(SangriaEntity $sangriaEntity)
    {
        return $this->sangriaRepository->createSangria($sangriaEntity);
    }

}
