<?php


namespace Core\CortesCaja\Application\CaseUse;


use Core\CortesCaja\Domain\Interfaces\CortesInterface;

class CreateUseCase
{
    /**
     * @var CortesInterface
     */
    private CortesInterface $cortes;

    public function __construct(CortesInterface $cortes)
    {
        $this->cortes = $cortes;
    }
    function GuardarCorte($detallecorteCaja,$corteCaja){
        return $this->cortes->GuardarCorte($detallecorteCaja,$corteCaja);
    }
}
