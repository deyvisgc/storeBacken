<?php


namespace Core\Almacen\Lote\Aplication\UseCases;


use Core\Almacen\Lote\Domain\Entity\LoteEntity;
use Core\Almacen\Lote\Domain\Repositories\LoteRepository;
use Core\Almacen\Lote\Domain\ValueObjects\L0TCREATIONDATE;
use Core\Almacen\Lote\Domain\ValueObjects\LOTCODIGO;
use Core\Almacen\Lote\Domain\ValueObjects\LOTEESPIRACIDATE;
use Core\Almacen\Lote\Domain\ValueObjects\LOTNAME;

class CreateCase
{


    /**
     * @var LoteRepository
     */
    private LoteRepository $repository;

    public function __construct(LoteRepository $repository)
    {
        $this->repository = $repository;
    }

    public function __invoke($accion,$lot_name,$lot_codigo,$lot_expiration_date,$lot_creation_date)
    {

        $nomb = new LOTNAME($lot_name);
        $lot_codigo = new LOTCODIGO($lot_codigo);
        $lot_expiration_date = new LOTEESPIRACIDATE($lot_expiration_date);
        $lot_creation_date = new L0TCREATIONDATE($lot_creation_date);
        $Producto = LoteEntity::create($nomb, $lot_codigo, $lot_expiration_date, $lot_creation_date);
        return $this->repository->Create($Producto,$accion);
    }

}
