<?php


namespace Core\Reportes\Application;


use Core\Reportes\Domain\InventarioRepository;

class InventarioUseCase
{

    /**
     * @var InventarioRepository
     */
    private InventarioRepository $inventxarioRepository;

    public function __construct(InventarioRepository  $inventarioRepository)
    {
        $this->inventxarioRepository = $inventarioRepository;
    }
    public function __Inventario($param)
    {
        return $this->inventxarioRepository->Inventario($param);
    }
}
