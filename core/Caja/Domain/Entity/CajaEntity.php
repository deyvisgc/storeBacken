<?php


namespace Core\Caja\Domain\Entity;


class CajaEntity
{
    private int $idCaja;
    private string $cajaName;
    private string $cajaDescription;
    private string $cajaStatus;
    private int $idUser;

    public function __construct(
        int $idCaja,
        string $cajaName,
        string $cajaDescription,
        string $cajaStatus,
        int $idUser
    )
    {
        $this->idCaja = $idCaja;
        $this->cajaName = $cajaName;
        $this->cajaDescription= $cajaDescription;
        $this->cajaStatus=$cajaStatus;
        $this->idUser=$idUser;
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
     * @return string
     */
    public function getCajaName(): string
    {
        return $this->cajaName;
    }

    /**
     * @param string $cajaName
     */
    public function setCajaName(string $cajaName): void
    {
        $this->cajaName = $cajaName;
    }

    /**
     * @return string
     */
    public function getCajaDescription(): string
    {
        return $this->cajaDescription;
    }

    /**
     * @param string $cajaDescription
     */
    public function setCajaDescription(string $cajaDescription): void
    {
        $this->cajaDescription = $cajaDescription;
    }

    /**
     * @return string
     */
    public function getCajaStatus(): string
    {
        return $this->cajaStatus;
    }

    /**
     * @param string $cajaStatus
     */
    public function setCajaStatus(string $cajaStatus): void
    {
        $this->cajaStatus = $cajaStatus;
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
            'id_caja'=>$this->idCaja,
            'ca_name'=>$this->cajaName,
            'ca_description'=>$this->cajaDescription,
            'ca_status'=>$this->cajaStatus,
            'id_user'=>$this->idUser
        ];
    }
}
