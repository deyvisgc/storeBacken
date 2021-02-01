<?php


namespace Core\Almacen\Unidad\Aplication\UseCases;


use Core\Almacen\Unidad\Domain\Repositories\UnidadRepository;

class DeleteCase
{


    /**
     * @var UnidadRepository
     */
    private UnidadRepository $repository;

    public function __construct(UnidadRepository $repository)
    {
        $this->repository = $repository;
    }
    public function __invokexid(int $id)
    {
        return $this->repository->delete($id);
    }

}
