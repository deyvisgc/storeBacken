<?php


namespace Core\Compras\Application\UseCase;


use Core\Compras\Domain\PagosRepository;

class PagosUceCase
{
    /**
     * @var PagosRepository
     */
    private PagosRepository $pagosRepository;

    public function __construct(PagosRepository  $pagosRepository)
    {
        $this->pagosRepository = $pagosRepository;
    }
    public function __PagosCredito($data)
    {
        return $this->pagosRepository->PagosCredito($data);
    }
}
