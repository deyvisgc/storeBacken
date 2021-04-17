<?php


namespace Core\CortesCaja\Infraestructura\Adapter;

use Core\CortesCaja\Application\CaseUse\CreateUseCase;
use Core\CortesCaja\Infraestructura\DataBase\CorteSql;

class CreateCorteAdapter
{
    /**
     * @var CorteSql
     */
    private CorteSql $corteSql;

    public function __construct(CorteSql $corteSql)
    {
        $this->corteSql = $corteSql;
    }
    function GuardarCorte($detallecorteCaja, $corteCaja) {
        $createCaja= new CreateUseCase($this->corteSql);
        return $createCaja->GuardarCorte($detallecorteCaja, $corteCaja);
    }
}
