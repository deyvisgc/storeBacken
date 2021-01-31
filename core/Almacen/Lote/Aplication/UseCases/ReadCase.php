<?php


namespace Core\Almacen\Lote\Aplication\UseCases;


use Core\Almacen\Lote\Domain\Repositories\LoteRepository;

class ReadCase
{


    /**
     * @var LoteRepository
     */
    private LoteRepository $repository;

    public function __construct(LoteRepository $repository)
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
