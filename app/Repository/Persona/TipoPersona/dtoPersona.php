<?php


namespace App\Repository\Persona\TipoPersona;


use Carbon\Carbon;

class dtoPersona
{
    private int $idPersona;
    private string $nombre;
    private string $razonSocial;
    private string $tipoDocumento;
    private int $numeroDocumento;
    private string $fechaCreacion;
    private string $codigoInterno;
    private string $departamento;
    private string $provincia;
    private string $distrito;
    private int $tipoCliente;
    private string $telefono;
    private string $email;
    private string $direccion;
    private string $perTipo;

    public function __construct(int $idPersona ,string $nombre, string $razonSocial, string $tipoDocumento, int $numeroDocumento, string $fechaCreacion,
                                string $codigoInterno, int $tipoCliente, string $departamento, string $provincia, string $distrito, string $direccion,
                                string $telefono, string $email, string $tipoPerson)
    {

        $this->idPersona = $idPersona;
        $this->nombre = $nombre;
        $this->razonSocial = $razonSocial;
        $this->tipoDocumento = $tipoDocumento;
        $this->numeroDocumento = $numeroDocumento;
        $this->fechaCreacion = $fechaCreacion;
        $this->codigoInterno = $codigoInterno;
        $this->tipoCliente = $tipoCliente;
        $this->departamento = $departamento;
        $this->provincia = $provincia;
        $this->distrito = $distrito;
        $this->direccion = $direccion;
        $this->telefono = $telefono;
        $this->email = $email;
        $this->perTipo = $tipoPerson;
    }

    public function getIdPersona(): int
    {
        return $this->idPersona;
    }

    public function getNombre(): string
    {
        return $this->nombre;
    }

    public function getRazonSocial(): string
    {
        return $this->razonSocial;
    }

    public function getTipoDocumento(): string
    {
        return $this->tipoDocumento;
    }

    public function getNumeroDocuento(): int
    {
        return $this->numeroDocumento;
    }

    public function getFechaCreacion(): string
    {
        return $this->fechaCreacion;
    }

    public function getCodigoInterno(): string
    {
        return $this->codigoInterno;
    }

    public function getDepartamento(): string
    {
        return $this->departamento;
    }

    public function getProvincia(): string
    {
        return $this->provincia;
    }

    public function getDistrito(): string
    {
        return $this->distrito;
    }

    public function getTipoCliente(): int
    {
        return $this->tipoCliente;
    }
    public function getDireccion(): string
    {
        return $this->direccion;
    }

    public function getTelefono(): string
    {
        return $this->telefono;
    }

    public function getEmail(): string
    {
        return $this->email;
    }
    public function getPerTipo(): string
    {
        return $this->perTipo;
    }
    function Person(string $accion) {
        $datos = array('per_nombre' => ucwords(strtolower($this->getNombre())),
            'per_razon_social' => ucwords(strtolower($this->getRazonSocial())),
            'per_tipo_documento' =>$this->getTipoDocumento(),
            'per_numero_documento' =>$this->getNumeroDocuento(),
            'per_codigo_interno' =>$this->getCodigoInterno(),
            'id_tipo_cliente_proveedor' =>$this->getTipoCliente() ? $this->getTipoCliente() : null,
            'per_fecha_creacion' => Carbon::make($this->getFechaCreacion())->format('Y-m-d'),
            'id_departamento' => $this->getDepartamento(),
            'id_provincia' => $this->getProvincia(),
            'id_distrito' =>$this->getDistrito(),
            'per_direccion' =>$this->getDireccion(),
            'per_celular' =>$this->getTelefono(),
            'per_email' =>$this->getEmail(),
            'per_tipo' => $this->getPerTipo());
        if ($accion === 'crear') {
           return array_merge(array('per_status' => 'active'), $datos); // aqui estoy agregando un nuevo elemento a mi array de objetos
        }
        return $datos;
    }
}
