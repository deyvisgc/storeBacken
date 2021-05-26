<?php


namespace Core\Producto\Domain\ValueObjects;


use Carbon\Carbon;

class FECHA
{
    private string $fecha;
    public function __construct(string $fecha)
    {
        $this->fecha = Carbon::make($fecha)->format('Y-m-d');
    }
    public function getFecha(): string
    {
        return $this->fecha;
    }

}
