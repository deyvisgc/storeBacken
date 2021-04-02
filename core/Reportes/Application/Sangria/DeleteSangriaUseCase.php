<?php


namespace Core\Reportes\Application\Sangria;


use Core\Reportes\Domain\SangriaRepository;

class DeleteSangriaUseCase
{
    public function __construct(SangriaRepository $repository)
    {
        $this->repository = $repository;
    }
    function deleteSangria($id) {
        return $this->repository->delete($id);
    }
}
