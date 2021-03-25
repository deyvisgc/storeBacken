<?php


namespace Core\Compras\Infraestructure\Adapter_Bridge;


use Core\Compras\Application\UseCase\PagosUceCase;
use Core\Compras\Domain\PagosRepository;
use Core\Compras\Infraestructure\Sql\PagosSql;

class PagosBridge
{


    public function __construct(PagosSql $repository)
    {
        $this->repository = $repository;
    }
    public function __Pagos($data)
    {
        $readcase= new PagosUceCase($this->repository);
        return $readcase->__PagosCredito($data);
    }

}
