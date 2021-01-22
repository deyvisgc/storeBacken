<?php


namespace Core\RegistroSanitario\Domain\ValueObjects;


class Codigo
{
    /**
     * @var string
     */
    private $codigo;

    public function __construct(string $codigo)
    {

        $this->codigo = $codigo;
    }

    /**
     * @return string
     */
    public function getCodigo(): string
    {
        return $this->codigo;
    }

    /**
     * @param string $codigo
     */
    public function setCodigo(string $codigo): void
    {
        $this->codigo = $codigo;
    }
}
