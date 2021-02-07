<?php


namespace Core\Almacen\Clase\Aplication\UseCases;



use Core\Almacen\Clase\Domain\Entity\ClaseEntity;
use Core\Almacen\Clase\Domain\Repositories\ClaseRepository;
use Core\Almacen\Clase\Domain\ValueObjects\CLASSNAME;
use Core\Almacen\Clase\Domain\ValueObjects\IDHIJO;

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

    public function __invoke(string $clasname, ?int $idclasesupe )
    {
        $name = new CLASSNAME($clasname);
        $idclasesupe= new IDHIJO($idclasesupe);
        $clase = ClaseEntity::create($name, $idclasesupe);
        return $this->repository->Create($clase);
    }

}
