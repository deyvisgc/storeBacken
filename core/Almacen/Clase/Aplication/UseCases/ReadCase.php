<?php


namespace Core\Almacen\Clase\Aplication\UseCases;



use Core\Almacen\Clase\Domain\Repositories\ClaseRepository;

class ReadCase
{


    public function __construct(ClaseRepository $repository)
    {
        $this->repository = $repository;
    }

    function getCategoria($params)
    {
        return $this->repository->getCategoria($params);
    }
    function editCategory($id)
    {
        return $this->repository->editCategory($id);
    }
    function searchCategoria($params) {
        return $this->repository->searchCategoria($params);
    }
    public function editSubcate($params) {
        return $this->repository->editSubcate($params);
    }

}
