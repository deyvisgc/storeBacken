<?php


namespace Core\Almacen\Unidad\Aplication\UseCases;


use Core\Almacen\Unidad\Domain\Repositories\UnidadRepository;

class ReadCase
{

    /**
     * @var UnidadRepository
     */
    private UnidadRepository $repository;

    public function __construct(UnidadRepository $repository)
    {
        $this->repository = $repository;
    }

     function __invoke($params)
    {
        return $this->repository->Read($params);
    }
    function SearchUnidad($params) {
        return $this->repository->SearchUnidad($params);
    }
    public function __invokexid(int $idproducto)
    {
        return $this->repository->Readxid($idproducto);
    }

}
