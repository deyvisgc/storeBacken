<?php


namespace Core\Reportes\Infraestructure\Adapter;


use Core\Reportes\Application\InventarioUseCase;
use Core\Reportes\Infraestructure\Sql\InvntarioSql;

class InventarioAdapter
{
    /**
     * @var InvntarioSql
     */
    private InvntarioSql $repository;

    public function __construct(InvntarioSql $repository)
    {
        $this->repository = $repository;
    }
    public function __Inventario($param)
    {
        $readcase= new InventarioUseCase($this->repository);
        return $readcase->__Inventario($param);
    }
}
