<?php


namespace Core\Almacen\Clase\Aplication\UseCases;



use Core\Almacen\Clase\Domain\Entity\ClaseEntity;
use Core\Almacen\Clase\Domain\Repositories\ClaseRepository;
use Core\Almacen\Clase\Domain\ValueObjects\CLASSNAME;
use Core\Almacen\Clase\Domain\ValueObjects\IDHIJO;
use Core\Almacen\Clase\Domain\ValueObjects\IDPADRE;

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

    public function create(int $idcategoria, string $clasname, int $clase_superior)
    {
        $idCate = new IDPADRE($idcategoria);
        $name = new CLASSNAME($clasname);
        $idClaseSupe = new IDHIJO($clase_superior);
        $clase = new ClaseEntity($idCate,$name,$idClaseSupe);
        return $this->repository->Categoria($clase);
    }

}
