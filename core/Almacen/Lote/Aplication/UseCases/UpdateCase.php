<?php


namespace Core\Almacen\Lote\Aplication\UseCases;




use Core\Almacen\Lote\Domain\Entity\LoteEntity;
use Core\Almacen\Lote\Domain\Repositories\LoteRepository;
use Core\Almacen\Lote\Domain\ValueObjects\L0TCREATIONDATE;
use Core\Almacen\Lote\Domain\ValueObjects\LOTCODIGO;
use Core\Almacen\Lote\Domain\ValueObjects\LOTEESPIRACIDATE;
use Core\Almacen\Lote\Domain\ValueObjects\LOTNAME;

class UpdateCase
{


    /**
     * @var LoteRepository
     */
    private LoteRepository $repository;

    public function __construct(LoteRepository $repository)
    {
        $this->repository = $repository;
    }

    public function __invoke($lot_name,$lot_codigo,$lot_expiration_date,$lot_creation_date,$id)
    {
        $nomb = new LOTNAME($lot_name);
        $lot_codigo = new LOTCODIGO($lot_codigo);
        $lot_expiration_date = new LOTEESPIRACIDATE($lot_expiration_date);
        $lot_creation_date = new L0TCREATIONDATE($lot_creation_date);
        $loteEntity = LoteEntity::update($nomb, $lot_codigo, $lot_expiration_date, $lot_creation_date);
        return $this->repository->Update($loteEntity, $id);
    }
     public function ChangeStatus(int $id, string $status) {
        return $this->repository->CambiarStatus($id, $status);
     }
}
