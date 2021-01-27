<?php


namespace Core\Sangria\Application\UseCases;


use Core\Sangria\Domain\Repositories\SagriaRepository;

class ListSangriaUseCase
{
    private SagriaRepository $sagriaRepository;

    public function __construct(SagriaRepository $sagriaRepository)
    {
        $this->sagriaRepository = $sagriaRepository;
    }
    public function listSangria()
    {
        return $this->sagriaRepository->listSangria();
    }
}

