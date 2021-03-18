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

    public function __invoke(int $id,string $um_name,string $nom_corto, $fecha_creacion)
    {
        $nomb = new UMNAME($um_name);
        $nom_cor = new UMNOMBRECORTO($nom_corto);
        $unidad = UnidadEntity::update($nomb, $nom_cor);
        return $this->repository->Update($unidad, $id, $fecha_creacion);
    }
     public function ChangeStatus(int $id, string $status) {
        return $this->repository->CambiarStatus($id, $status);
     }
}
