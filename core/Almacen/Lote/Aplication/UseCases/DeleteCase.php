<?php


namespace Core\Almacen\Lote\Aplication\UseCases;

use Core\Almacen\Lote\Domain\Repositories\LoteRepository;

class DeleteCase
{


    /**
     * @var LoteRepository
     */
    private LoteRepository $repository;

    public function __construct(LoteRepository $repository)
    {
        $this->repository = $repository;
    }
    public function __invokexid(int $idproducto)
    {
        return $this->repository->delete($idproducto);
    }

}
