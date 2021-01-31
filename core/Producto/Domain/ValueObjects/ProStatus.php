<?php


namespace Core\Producto\Domain\ValueObjects;


class ProStatus
{
    private string $ProStatus;

    public function __construct(string $ProStatus)
    {
        $this->ProStatus = $ProStatus;
    }
    public function getProStatus(): string
    {
        return $this->ProStatus;
    }

}
