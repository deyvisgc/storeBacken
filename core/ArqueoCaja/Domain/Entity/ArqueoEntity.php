<?php


namespace Core\ArqueoCaja\Domain\Entity;

class ArqueoEntity
{


    private $fecha;
    private $hora;
    private int $idCaja;
    private string $empresa;
    private float $totalMonedas;
    private float $totalBilletes;
    private float $cajaApertura;
    private float $totalVenta;
    private float $totalCorte;
    private float $sobrantes;
    private float $faltantes;
    private string $observaciones;

    public function __construct($fecha, $hora, int $idCaja, string $empresa, float $totalMonedas, float $totalBilletes,
                                float $cajaApertura, float $totalVenta, float $totalCorte, float $sobrantes, float $faltantes,
                                string $observaciones)
    {


        $this->fecha = $fecha;
        $this->hora = $hora;
        $this->idCaja = $idCaja;
        $this->empresa = $empresa;
        $this->totalMonedas = $totalMonedas;
        $this->totalBilletes = $totalBilletes;
        $this->cajaApertura = $cajaApertura;
        $this->totalVenta = $totalVenta;
        $this->totalCorte = $totalCorte;
        $this->sobrantes = $sobrantes;
        $this->faltantes = $faltantes;
        $this->observaciones = $observaciones;
    }

    /**
     * @return mixed
     */
    public function getFecha()
    {
        return $this->fecha;
    }

    /**
     * @return mixed
     */
    public function getHora()
    {
        return $this->hora;
    }

    /**
     * @return int
     */
    public function getIdCaja(): int
    {
        return $this->idCaja;
    }

    /**
     * @return string
     */
    public function getEmpresa(): string
    {
        return $this->empresa;
    }

    /**
     * @return float
     */
    public function getTotalMonedas(): float
    {
        return $this->totalMonedas;
    }

    /**
     * @return float
     */
    public function getTotalBilletes(): float
    {
        return $this->totalBilletes;
    }

    /**
     * @return float
     */
    public function getCajaApertura(): float
    {
        return $this->cajaApertura;
    }

    /**
     * @return float
     */
    public function getTotalVenta(): float
    {
        return $this->totalVenta;
    }

    /**
     * @return float
     */
    public function getTotalCorte(): float
    {
        return $this->totalCorte;
    }

    /**
     * @return float
     */
    public function getSobrantes(): float
    {
        return $this->sobrantes;
    }

    /**
     * @return float
     */
    public function getFaltantes(): float
    {
        return $this->faltantes;
    }

    /**
     * @return string
     */
    public function getObservaciones(): string
    {
        return $this->observaciones;
    }

     function Create() {
        return  array(
                      'fecha_arqueo' => $this->getFecha(),
                      'hora_arqueo' => $this->getHora(),
                      'id_caja' => $this->getIdCaja(),
                      'empresa_arqueo' => $this->getEmpresa(),
                      'total_monedas_arqueo' =>$this->getTotalMonedas(),
                      'total_billetes_arqueo' =>  $this->getTotalBilletes(),
                      'caja_apertura_arqueo' => $this->getCajaApertura(),
                      'total_venta_arqueo' => $this->getTotalVenta(),
                      'total_corte_arqueo' =>$this->getTotalCorte(),
                      'sobrantes_arqueo' => $this->getSobrantes(),
                      'faltantes_arqueo' => $this->getFaltantes(),
                      'observacion_arqueo' => $this->getObservaciones(),
        );
    }
}
