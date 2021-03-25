<?php


namespace Core\Compras\Infraestructure\Adapter_Bridge;


use Core\Compras\Application\UseCase\ReadUseCase;
use Core\Compras\Infraestructure\Sql\ReadRepository;

class ReadBridge
{
    /**
     * @var ReadRepository
     */
    private ReadRepository $repository;

    public function __construct(ReadRepository $repository)
    {
        $this->repository = $repository;
    }
    public function __invoke($params)
    {
        $readcase= new ReadUseCase($this->repository);
        return $readcase->__invoke($params);
    }
    public function __Detalle($id)
    {
        $readcase= new ReadUseCase($this->repository);
        return $readcase->__Detalle($id);
    }
    public function __Filtros($data) {
        return $data;
        $readcase = new ReadUseCase($this->repository);
        $readcase->__Filtros($data);
    }
}
