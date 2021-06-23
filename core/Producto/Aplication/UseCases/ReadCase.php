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

     function __invoke($params)
    {
        return $this->repository->Read($params);
    }
     function Edit($params)
    {
        return $this->repository->Edit($params);
    }
     function __invokeLastId() {
        return $this->repository->LastIdProduct();
    }
     function search($params) {
        return $this->repository->search($params);
     }
    function selectProducto($params)
    {
        return $this->repository->selectProducto($params);
    }


}
