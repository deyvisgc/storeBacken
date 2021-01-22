<?php


namespace Core\RegistroSanitario\Domain\Entity;


use Core\RegistroSanitario\Domain\ValueObjects\Codigo;
use Core\RegistroSanitario\Domain\ValueObjects\Description;
use Core\RegistroSanitario\Domain\ValueObjects\FechaVencimiento;
use Core\RegistroSanitario\Domain\ValueObjects\IdRegistroSanitario;

class RegistroSanitarioEntity
{
    /**
     * @var IdRegistroSanitario
     */
    private IdRegistroSanitario $idRegistroSanitario;
    /**
     * @var Codigo
     */
    private Codigo $codigo;
    /**
     * @var FechaVencimiento
     */
    private $fechaVencimiento;
    /**
     * @var Description
     */
    private $description;

    public function __construct(IdRegistroSanitario $idRegistroSanitario, Codigo $codigo, FechaVencimiento $fechaVencimiento, Description $description)
    {
        $this->idRegistroSanitario = $idRegistroSanitario;
        $this->codigo = $codigo;
        $this->fechaVencimiento = $fechaVencimiento;
        $this->description = $description;
    }

    /**
     * @return IdRegistroSanitario
     */
    public function getIdRegistroSanitario(): IdRegistroSanitario
    {
        return $this->idRegistroSanitario;
    }

    /**
     * @return Codigo
     */
    public function getCodigo(): Codigo
    {
        return $this->codigo;
    }

    /**
     * @return FechaVencimiento
     */
    public function getFechaVencimiento(): FechaVencimiento
    {
        return $this->fechaVencimiento;
    }

    /**
     * @return Description
     */
    public function getDescription(): Description
    {
        return $this->description;
    }

    public function toArray():array
    {
        return [
            'rs_codigo' => $this->codigo->getCodigo(),
            'rs_fecha_vencimiento' => $this->fechaVencimiento->getFechaVencimiento(),
            'rs_description' => $this->description->getDescription(),
        ];
    }
}
