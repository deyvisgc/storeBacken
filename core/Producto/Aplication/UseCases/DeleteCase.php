<?php


namespace Core\Producto\Aplication\UseCases;

use Core\Almacen\Clase\Domain\Repositories\ClaseRepository;
use Core\Producto\Domain\Repositories\ProductoRepository;

class DeleteCase
{


    /**
     * @var ClaseRepository
     */
    private ClaseRepository $repository;

    public function __construct(ClaseRepository $repository)
    {

        $this->repository = $repository;
    }
    public function __invokexid(int $idclase)
    {
        return $this->repository->delete($idclase);
    }

}
