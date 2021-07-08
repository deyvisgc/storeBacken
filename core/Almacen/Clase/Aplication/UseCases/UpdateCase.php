<?php


namespace Core\Almacen\Clase\Aplication\UseCases;


use Core\Almacen\Clase\Domain\Entity\ClaseEntity;
use Core\Almacen\Clase\Domain\Repositories\ClaseRepository;
use Core\Almacen\Clase\Domain\ValueObjects\CLASSNAME;
use Core\Almacen\Clase\Domain\ValueObjects\IDHIJO;
use Core\Almacen\Clase\Domain\ValueObjects\IDPADRE;

class UpdateCase
{


    /**
     * @var ClaseRepository
     */
    private ClaseRepository $repository;

    public function __construct(ClaseRepository $repository)
    {
        $this->repository = $repository;
    }
     public function ChangeStatus(int $idclase, string $status) {
         return $this->repository->ChangeStatusCate($idclase,$status);
     }

    public function ChangeStatusSubCate(int $idclase, string $status) {
        return $this->repository->ChangeStatusSubCate($idclase,$status);
    }
}
