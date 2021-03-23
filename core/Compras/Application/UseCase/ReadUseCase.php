<?php


namespace Core\Compras\Application\UseCase;


use Core\Compras\Domain\ComprasRepository;
use Core\Compras\Infraestructure\Sql\ReadRepository;

class ReadUseCase
{
    /**
     * @var ComprasRepository
     */
    private ComprasRepository $repository;

    public function __construct(ComprasRepository $repository)
    {
        $this->repository = $repository;
    }

    public function __invoke($params)
    {
        return $this->repository->Read($params);
    }
    public function __Detalle($id)
    {
        return $this->repository->Detalle($id);
    }
}
