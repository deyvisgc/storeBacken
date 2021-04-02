<?php


namespace Core\Reportes\Application\Sangria;


use Core\Reportes\Domain\SangriaRepository;

class ReadSangriaUseCase
{
    public function __construct(SangriaRepository $repository)
    {
        $this->repository = $repository;
    }
    function Read($params) {
     return $this->repository->Read($params);
    }
}
