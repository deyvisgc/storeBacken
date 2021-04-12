<?php


namespace Core\ArqueoCaja\Infraestructure\Adapter;


use Core\ArqueoCaja\Application\UseCase\CreateUseCase;
use Core\ArqueoCaja\Domain\Entity\ArqueoEntity;
use Core\ArqueoCaja\Infraestructure\Database\ArqueoSql;
use Illuminate\Http\Request;

class ArqueoCreateAdapter
{
    /**
     * @var ArqueoSql
     */
    private ArqueoSql $arqueoSql;

    public function __construct(ArqueoSql $arqueoSql)
    {
        $this->arqueoSql = $arqueoSql;
    }
    function Create($request) {
        $fecha = $request['fecha'];
        $hora = $request['hora'];
        $idCaja= $request['idCaja'];
        $empresa = $request['empresa'];
        $totalMonedas = $request['totalMonedas'];
        $totalBilletes = $request['totalBilletes'];
        $cajaApertura = $request['cajaApertura'];
        $totalVenta   = $request['totalVenta'];
        $totalCorte = $request['totalCorte'];
        $sobrantes = $request['sobrantes'];
        $faltantes  = $request['faltantes'];
        $observaciones = $request['observaciones'];
        $arqueo = new ArqueoEntity($fecha, $hora, $idCaja, $empresa, (float)$totalMonedas, (float)$totalBilletes, (float)$cajaApertura, (float)$totalVenta, (float)$totalCorte, (float)$sobrantes, (float)$faltantes, $observaciones);
        $createUseCase = new CreateUseCase($this->arqueoSql);
       return $createUseCase->create($arqueo);
    }
}
