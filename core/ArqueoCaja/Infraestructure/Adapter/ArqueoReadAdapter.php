<?php


namespace Core\ArqueoCaja\Infraestructure\Adapter;


use Core\ArqueoCaja\Application\UseCase\ReadUseCase;
use Core\ArqueoCaja\Domain\Interfaces\ArqueoCajaRepository;
use Core\ArqueoCaja\Infraestructure\Database\ArqueoSql;

class ArqueoReadAdapter
{

    /**
     * @var ArqueoSql
     */
    private ArqueoSql $arqueoSql;

    public function __construct(ArqueoSql $arqueoSql)
    {
        $this->arqueoSql = $arqueoSql;
    }
    function ObtenerTotales($params) {
        $readCase = new ReadUseCase($this->arqueoSql);
        return $readCase->ObtenerTotales($params);
    }
}
