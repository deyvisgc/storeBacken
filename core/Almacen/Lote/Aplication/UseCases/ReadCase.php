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

     function __invoke($request)
    {
        return $this->repository->Read($request);
    }
    function SearchLotes($params) {
        return $this->repository->SearchLotes($params);
    }
     function __invokexid(int $idproducto)
    {
        return $this->repository->Readxid($idproducto);
    }

}
