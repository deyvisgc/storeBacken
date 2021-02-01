<?php


namespace Core\Almacen\Lote\Domain\ValueObjects;


class LOTNAME
{
    private string $lotname;

    public function __construct(string $lotname)
    {
        $this->lotname = $lotname;
    }

    /**
     * @return string
     */
    public function getLotname(): string
    {
        return $this->lotname;
    }

}
