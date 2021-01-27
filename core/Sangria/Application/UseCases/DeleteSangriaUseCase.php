<?php


namespace Core\Sangria\Application\UseCases;


use Core\Sangria\Domain\Repositories\SagriaRepository;

class DeleteSangriaUseCase
{
    private SagriaRepository $sagriaRepository;

    public function __construct(SagriaRepository $sagriaRepository)
    {
        $this->sagriaRepository=$sagriaRepository;
    }
    public function deleteSangria($idSangria)
    {
        return $this->sagriaRepository->deleteSangria($idSangria);
    }
}
