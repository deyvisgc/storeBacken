<?php


namespace App\Repository\Persona\TipoPersona;


use Carbon\Carbon;

class dtoTipoCliente
{
    private int $id;
    private string $descripcion;

    public function __construct(int $id, string  $descripcion)
    {
        $this->id = $id;
        $this->descripcion = $descripcion;
    }

    /**
     * @return int
     */
    public function getId(): int
    {
        return $this->id;
    }

    /**
     * @return string
     */
    public function getDescripcion(): string
    {
        return $this->descripcion;
    }

    function tipoCliente($accion) {
        $datos = array(
            'descripcion' => ucwords(strtolower($this->getDescripcion())),
            'tipo_fecha_creacion' => Carbon::now()->format('Y-m-d'));
        if ($accion === 'crear') {
            return array_merge(array('tipo_estado' => 'active'), $datos); // aqui estoy agregando un nuevo elemento a mi array de objetos
        }
        return $datos;
    }
}
