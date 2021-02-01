<?php


namespace Core\RegistroSanitario\Domain\Entity;


use Core\RegistroSanitario\Domain\ValueObjects\ProNombre;
use Core\RegistroSanitario\Domain\ValueObjects\ProPrecioCompra;
use Core\RegistroSanitario\Domain\ValueObjects\ProPrecioVenta;
use Core\RegistroSanitario\Domain\ValueObjects\ProCantidad;

class RegistroSanitarioEntity
{
    /**
     * @var ProCantidad
     */
    private int $idRegistroSanitario;
    /**
     * @var ProNombre
     */
    private string $codigo;
    /**
     * @var ProPrecioVenta
     */
    private string $fechaVencimiento;
    /**
     * @var ProPrecioCompra
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
     * @return ProCantidad
     */
    public function getIdRegistroSanitario()
    {
        return $this->idRegistroSanitario;
    }

    /**
     * @param ProCantidad $idRegistroSanitario
     */
    public function setIdRegistroSanitario($idRegistroSanitario): void
    {
        $this->idRegistroSanitario = $idRegistroSanitario;
    }

    /**
     * @return ProNombre
     */
    public function getCodigo()
    {
        return $this->codigo;
    }

    /**
     * @param ProNombre $codigo
     */
    public function setCodigo($codigo): void
    {
        $this->codigo = $codigo;
    }

    /**
     * @return ProPrecioVenta
     */
    public function getFechaVencimiento()
    {
        return $this->fechaVencimiento;
    }

    /**
     * @param ProPrecioVenta $fechaVencimiento
     */
    public function setFechaVencimiento($fechaVencimiento): void
    {
        $this->fechaVencimiento = $fechaVencimiento;
    }

    /**
     * @return ProPrecioCompra
     */
    public function getDescription()
    {
        return $this->description;
    }

    /**
     * @param ProPrecioCompra $description
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
