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
    private int $idRegistroSanitario;
    /**
     * @var Codigo
     */
    private string $codigo;
    /**
     * @var FechaVencimiento
     */
    private string $fechaVencimiento;
    /**
     * @var Description
     */
    private string $description;

    public function __construct(int $idRegistroSanitario, string $codigo, string $fechaVencimiento, string $description)
    {
        $this->idRegistroSanitario = $idRegistroSanitario;
        $this->codigo = $codigo;
        $this->fechaVencimiento = $fechaVencimiento;
        $this->description = $description;
    }

    /**
     * @return IdRegistroSanitario
     */
    public function getIdRegistroSanitario()
    {
        return $this->idRegistroSanitario;
    }

    /**
     * @param IdRegistroSanitario $idRegistroSanitario
     */
    public function setIdRegistroSanitario($idRegistroSanitario): void
    {
        $this->idRegistroSanitario = $idRegistroSanitario;
    }

    /**
     * @return Codigo
     */
    public function getCodigo()
    {
        return $this->codigo;
    }

    /**
     * @param Codigo $codigo
     */
    public function setCodigo($codigo): void
    {
        $this->codigo = $codigo;
    }

    /**
     * @return FechaVencimiento
     */
    public function getFechaVencimiento()
    {
        return $this->fechaVencimiento;
    }

    /**
     * @param FechaVencimiento $fechaVencimiento
     */
    public function setFechaVencimiento($fechaVencimiento): void
    {
        $this->fechaVencimiento = $fechaVencimiento;
    }

    /**
     * @return Description
     */
    public function getDescription()
    {
        return $this->description;
    }

    /**
     * @param Description $description
     */
    public function setDescription($description): void
    {
        $this->description = $description;
    }



    public function toArray():array
    {
        return [
            'id_registro_sanitario' => $this->idRegistroSanitario,
            'rs_codigo' => $this->codigo,
            'rs_fecha_vencimiento' => $this->fechaVencimiento,
            'rs_description' => $this->description,
        ];
    }
}
