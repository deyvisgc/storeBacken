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

    public function __invoke(string $accion,int $idpadre,int $idhijo)
    {
        $id_padre=new IDPADRE($idpadre);
        $id_hijo= new IDHIJO($idhijo);
        $Clase = ClaseEntity::update($id_padre, $id_hijo);
        return $this->repository->Update($Clase);
    }
    public function Actualizaracate(int $idclase,string $namecate)
    {
        return $this->repository->Actualizarcate($idclase,$namecate);
    }
     public function ChangeStatus(int $idclase, string $status) {
         return $this->repository->ChangeStatusCate($idclase,$status);
     }

    public function ChangeStatusRecursiva(int $idclase, string $status) {
        return $this->repository->ChangeStatusCateRecursiva($idclase,$status);
    }
}
