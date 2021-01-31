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

    public function __invoke()
    {
        return $this->repository->Read();
    }
    public function __invokexid(int $idproducto)
    {
        return $this->repository->Readxid($idproducto);
    }

}
