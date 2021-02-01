<?php


namespace Core\Producto\Aplication\UseCases;

use Core\Almacen\Clase\Domain\Repositories\ClaseRepository;
use Core\Producto\Domain\Repositories\ProductoRepository;

class DeleteCase
{


    /**
     * @var ProductoRepository
     */
    private ProductoRepository $repository;

    public function __construct(ProductoRepository $repository)
    {

        $this->repository = $repository;
    }
    public function __invokexid(int $idclase)
    {
        return $this->repository->delete($idclase);
    }

}
