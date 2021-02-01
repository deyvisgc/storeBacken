<?php


namespace Core\Almacen\Unidad\Aplication\UseCases;


use Core\Almacen\Unidad\Domain\Entity\UnidadEntity;
use Core\Almacen\Unidad\Domain\Repositories\UnidadRepository;
use Core\Almacen\Unidad\Domain\ValueObjects\UMNAME;
use Core\Almacen\Unidad\Domain\ValueObjects\UMNOMBRECORTO;


class UpdateCase
{


    /**
     * @var UnidadRepository
     */
    private UnidadRepository $repository;

    public function __construct(UnidadRepository $repository)
    {
        $this->repository = $repository;
    }

    public function __invoke(int $id, string $accion,string $um_name,string $nom_corto)
    {
        $nomb = new UMNAME($um_name);
        $nom_cor = new UMNOMBRECORTO($nom_corto);
        $unidad = UnidadEntity::update($nomb, $nom_cor);
        return $this->repository->Update($unidad, $id, $accion);
    }
     public function ChangeStatus(int $status) {

     }
}
