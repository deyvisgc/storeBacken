<?php


namespace Core\Almacen\Lote\Domain\ValueObjects;


class LOTEESPIRACIDATE
{
    private string $expridatedate;

    public function __construct(string $expridatedate)
 {
     $this->expridatedate = $expridatedate;
 }

    /**
     * @return string
     */
    public function getExpridatedate(): string
    {
        return $this->expridatedate;
    }

}
