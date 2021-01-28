<?php


namespace Core\HistorialCaja\Domain\Entity;


class HistorialCajaEntity
{
    private int $idCajaHistory;
    private string $chDate;
    private string $chTypeOperation;
    private float $chTotal;
    private int $idUser;
    private int $idCaja;

    public function __construct(
        int $idCajaHistory,
        string $chDate,
        string $chTypeOperation,
        float $chTotal,
        int $idUser,
        int $idCaja
    )
    {
        $this->idCajaHistory = $idCajaHistory;
        $this->chDate=$chDate;
        $this->chTypeOperation =$chTypeOperation;
        $this->chTotal=$chTotal;
        $this->idUser=$idUser;
        $this->idCaja=$idCaja;
    }

    /**
     * @return int
     */
    public function getIdCajaHistory(): int
    {
        return $this->idCajaHistory;
    }

    /**
     * @param int $idCajaHistory
     */
    public function setIdCajaHistory(int $idCajaHistory): void
    {
        $this->idCajaHistory = $idCajaHistory;
    }

    /**
     * @return string
     */
    public function getChDate(): string
    {
        return $this->chDate;
    }

    /**
     * @param string $chDate
     */
    public function setChDate(string $chDate): void
    {
        $this->chDate = $chDate;
    }

    /**
     * @return string
     */
    public function getChTypeOperation(): string
    {
        return $this->chTypeOperation;
    }

    /**
     * @param string $chTypeOperation
     */
    public function setChTypeOperation(string $chTypeOperation): void
    {
        $this->chTypeOperation = $chTypeOperation;
    }

    /**
     * @return float
     */
    public function getChTotal(): float
    {
        return $this->chTotal;
    }

    /**
     * @param float $chTotal
     */
    public function setChTotal(float $chTotal): void
    {
        $this->chTotal = $chTotal;
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


    public function toArray():array{
        return [
            'id_caja_historial'=>$this->idCajaHistory,
            'ch_fecha_operacion'=>$this->chDate,
            'ch_tipo_operacion'=>$this->chTypeOperation,
            'ch_total_dinero'=>$this->chTotal,
            'id_user'=>$this->idUser,
            'id_caja'=>$this->idCaja
        ];
    }
}
