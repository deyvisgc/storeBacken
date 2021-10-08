<?php


namespace App\Repository\Inventario\Movimientos\Entity;


use Carbon\Carbon;

class dtoRetiroStockAlmacen
{
    private int $idProducto;
    private int $id_almacen;
    private int $stockRetira;
    private string $motivoRetiro;
    private string $usuario;
    private int $id;
    private int $stockActual;

    public function __construct(int $id, int $idProducto, int $id_almacen, int $stockActual, int $stockRetira, string $motivoRetiro, string $usuario)
    {
        $this->idProducto = $idProducto;
        $this->id_almacen = $id_almacen;
        $this->stockRetira = $stockRetira;
        $this->motivoRetiro = $motivoRetiro;
        $this->usuario = $usuario;
        $this->id = $id;
        $this->stockActual = $stockActual;
    }

    /**
     * @return int
     */
    public function getIdProducto(): int
    {
        return $this->idProducto;
    }

    /**
     * @return int
     */
    public function getIdAlmacen(): int
    {
        return $this->id_almacen;
    }
    /**
     * @return int
     */
    public function getStockRetira(): int
    {
        return $this->stockRetira;
    }

    /**
     * @return string
     */
    public function getMotivoRetiro(): string
    {
        return $this->motivoRetiro;
    }

    /**
     * @return string
     */
    public function getUsuario(): string
    {
        return $this->usuario;
    }

    /**
     * @return int
     */
    public function getId(): int
    {
        return $this->id;
    }

    /**
     * @return int
     */
    public function getStockActual(): int
    {
        return $this->stockActual;
    }

    public function toArray() {
        return [
            'id_producto'=> $this->getIdProducto(),
            'id_almacen' => $this->getIdAlmacen(),
            'fecha_retiro' => Carbon::now(new \DateTimeZone('America/Lima'))->format('Y-m-d H:i'),
            'stock_retirado' => $this->getStockRetira(),
            'motivo_retiro' => $this->getMotivoRetiro(),
            'usuario' => $this->getUsuario()
        ];
    }
}
