<?php


namespace Core\RegistroSanitario\Domain\ValueObjects;


class FechaVencimiento
{
    /**
     * @var string
     */
    private $fechaVencimiento;

    public function __construct(string $fechaVencimiento)
    {
        $this->fechaVencimiento = $fechaVencimiento;
    }

    /**
     * @return string
     */
    public function getFechaVencimiento(): string
    {
        return $this->fechaVencimiento;
    }

    /**
     * @param string $fechaVencimiento
     */
    public function setFechaVencimiento(string $fechaVencimiento): void
    {
        $this->fechaVencimiento = $fechaVencimiento;
    }
}
