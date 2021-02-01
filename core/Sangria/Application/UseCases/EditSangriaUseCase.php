<?php


namespace Core\Sangria\Application\UseCases;



use Core\Sangria\Domain\Entity\SangriaEntity;
use Core\Sangria\Domain\Repositories\SagriaRepository;

class EditSangriaUseCase
{
    private SagriaRepository $sagriaRepository;

    public function __construct(SagriaRepository $sagriaRepository)
    {
        $this->sagriaRepository = $sagriaRepository;
    }
    public function editSangria (SangriaEntity $sangriaEntity)
    {
        return $this->sagriaRepository->editSangria($sangriaEntity);
    }
}
