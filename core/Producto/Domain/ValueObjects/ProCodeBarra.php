<?php


namespace Core\Producto\Domain\ValueObjects;


class ProCodeBarra
{

    private string $barra;

    public function __construct(string  $barra)
    {

        $this->barra = $barra;
    }
    public function getBarra(): string
    {
        return $this->barra;
    }
    public function setBarra(ProCodeBarra $barra): void
    {
        $this->barra = $barra;
    }

}
