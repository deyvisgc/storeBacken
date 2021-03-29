<?php


namespace Core\Compras\Application\UseCase;


use Core\Compras\Domain\ComprasRepository;

class UpdateUseCase
{

    public function __construct(ComprasRepository $repository)
    {
        $this->repository = $repository;
    }
    public function __invokeStatus($id)
    {
        return $this->repository->UpdateStatus($id);
    }
}
