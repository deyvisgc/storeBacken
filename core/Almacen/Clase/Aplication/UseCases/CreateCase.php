<?php


namespace Core\Almacen\Clase\Aplication\UseCases;



use Core\Almacen\Clase\Domain\Entity\ClaseEntity;
use Core\Almacen\Clase\Domain\Repositories\ClaseRepository;
use Core\Almacen\Clase\Domain\ValueObjects\CLASSNAME;
use Core\Almacen\Clase\Domain\ValueObjects\IDCLASESUPERIOR;

class CreateCase
{
    /**
     * @var ClaseRepository
     */
    private ClaseRepository $repository;

    public function __construct(ClaseRepository $repository)
    {
        $this->repository = $repository;
    }

    public function __invoke(string $accion,string $clasname,int $idclasesupe )
    {
        $name = new CLASSNAME($clasname);
        $idclasesupe= new IDCLASESUPERIOR($idclasesupe);
        $clase = ClaseEntity::create($name, $idclasesupe);
        return $this->repository->Create($clase,$accion);
    }

}
