<?php


namespace Core\Sangria\Domain\Entity;


class SangriaEntity
{
    private int $idSangria;
    private float $sanMonto;
    private string $sanFecha;
    private string $sanTipo;
    private string $sanMotivo;
    private int $idCaja;
    private int $idUser;

    public function __construct(
        int $idSangria,
        float $sanMonto,
        string $sanFecha,
        string $sanTipo,
        string $sanMotivo,
        int $idCaja,
        int $idUser
    )
    {
        $this->idSangria = $idSangria;
        $this->sanMonto = $sanMonto;
        $this->sanFecha = $sanFecha;
        $this->sanTipo = $sanTipo;
        $this->sanMotivo=$sanMotivo;
        $this->idCaja=$idCaja;
        $this->idUser=$idUser;
    }

    /**
     * @return int
     */
    public function getIdSangria(): int
    {
        return $this->idSangria;
    }

    /**
     * @param int $idSangria
     */
    public function setIdSangria(int $idSangria): void
    {
        $this->idSangria = $idSangria;
    }

    /**
     * @return float
     */
    public function getSanMonto(): float
    {
        return $this->sanMonto;
    }

    /**
     * @param float $sanMonto
     */
    public function setSanMonto(float $sanMonto): void
    {
        $this->sanMonto = $sanMonto;
    }



    /**
     * @return string
     */
    public function getSanFecha(): string
    {
        return $this->sanFecha;
    }

    /**
     * @param string $sanFecha
     */
    public function setSanFecha(string $sanFecha): void
    {
        $this->sanFecha = $sanFecha;
    }

    /**
     * @return string
     */
    public function getSanTipo(): string
    {
        return $this->sanTipo;
    }

    /**
     * @param string $sanTipo
     */
    public function setSanTipo(string $sanTipo): void
    {
        $this->sanTipo = $sanTipo;
    }

    /**
     * @return string
     */
    public function getSanMotivo(): string
    {
        return $this->sanMotivo;
    }

    /**
     * @param string $sanMotivo
     */
    public function setSanMotivo(string $sanMotivo): void
    {
        $this->sanMotivo = $sanMotivo;
    }

    /**
     * @return int
     */
    public function getIdCaja(): int
    {
        return $this->idCaja;
    }

    /**
     * @param int $idCaja
     */
    public function setIdCaja(int $idCaja): void
    {
        $this->idCaja = $idCaja;
    }

    /**
     * @return int
     */
    public function getIdUser(): int
    {
        return $this->idUser;
    }

    /**
     * @param int $idUser
     */
    public function setIdUser(int $idUser): void
    {
        $this->idUser = $idUser;
    }
    public function toArray():array
    {
        return [
            'id_sangria'=>$this->idSangria,
            'san_monto'=>$this->sanMonto,
            'san_fecha'=>$this->sanFecha,
            'san_tipo_sangria'=>$this->sanTipo,
            'san_motivo'=>$this->sanMotivo,
            'id_caja'=>$this->idCaja,
            'id_user'=>$this->idUser
        ];
    }

}
