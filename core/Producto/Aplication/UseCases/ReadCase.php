<?php


namespace Core\Producto\Aplication\UseCases;



use Core\Almacen\Clase\Domain\Repositories\ClaseRepository;
use Core\Producto\Domain\Repositories\ProductoRepository;


class ReadCase
{


    /**
     * @var ProductoRepository
     */
    private ProductoRepository $repository;

    public function __construct(ProductoRepository $repository)
    {
        $this->repository = $repository;
    }

    public function __invoke()
    {
        return $this->repository->Read();
    }
    public function __invokexid(int $idproducto)
    {
        return $this->repository->Readxid($idproducto);
    }
    public function __invokeLastId() {
        return $this->repository->LastIdProduct();
    }

}
