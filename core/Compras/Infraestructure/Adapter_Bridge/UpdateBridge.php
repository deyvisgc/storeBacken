<?php


namespace Core\Compras\Infraestructure\Adapter_Bridge;

use Core\Compras\Application\UseCase\UpdateUseCase;
use Core\Compras\Infraestructure\Sql\ReadRepository;

class UpdateBridge
{
    public function __construct(ReadRepository $repository)
    {
        $this->repository = $repository;
    }
    public function __invokeUpdate($id)
    {
        $readcase= new UpdateUseCase($this->repository);
        return $readcase->__invokeStatus($id);
    }
}
