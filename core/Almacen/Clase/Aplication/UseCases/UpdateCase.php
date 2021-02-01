<?php


namespace Core\Almacen\Clase\Aplication\UseCases;


use Core\Almacen\Clase\Domain\Entity\ClaseEntity;
use Core\Almacen\Clase\Domain\Repositories\ClaseRepository;
use Core\Almacen\Clase\Domain\ValueObjects\CLASSNAME;
use Core\Almacen\Clase\Domain\ValueObjects\IDCLASESUPERIOR;

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

    public function __invoke(string $accion,string $classnname,int $idclasesupe,int $idclase)
    {

        $nname=new CLASSNAME($classnname);
        $idclasesupe= new IDCLASESUPERIOR($idclasesupe);
        $Producto = ClaseEntity::update($nname, $idclasesupe);
        return $this->repository->Update($Producto,$idclase,$accion);
    }
     public function ChangeStatus(int $status) {

     }
}
