<?php


namespace Core\Reportes\Infraestructure\Sql;


use App\Http\Excepciones\Exepciones;
use Carbon\Carbon;
use Core\Reportes\Domain\SangriaRepository;
use Core\Traits\CajaTraits;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;
class SangriaSql implements SangriaRepository
{
    use CajaTraits;
    function AddSangria($data)
    {
        DB::beginTransaction();
        try {
            $statusCaja= $this->ActualizarMontoCaja($data->sangria['idCaja'],$data->sangria['idUsuario'],$data->sangria['monto'],$data->sangria['fecha'],$data->sangria['tipoSangria']);
            if ($statusCaja[0]) {
                if ($data->sangria['id'] <= 0) { // crear
                    $idSangria = DB::table('sangria')
                        ->insertGetId([
                            'san_monto'=>$data->sangria['monto'],
                            'san_fecha' =>$data->sangria['fecha'],
                            'san_tipo_sangria' => $data->sangria['tipoSangria'],
                            'san_motivo' => $data->sangria['motivo'],
                            'id_caja' =>$data->sangria['idCaja'],
                            'id_user' =>$data->sangria['idUsuario']
                        ]);
                    if ($idSangria > 0) {
                        $message = 'La sangria numero '.''. $idSangria.' fue creada correctamente';
                        $status = true; $code = 200;

                    } else {
                        $message = 'Error al crear sangria';
                        $status = false; $code = 402 ;
                    }
                } else {
                    $idSangria = DB::table('sangria')->where('id_sangria', $data->sangria['id'])->update([
                        'san_monto'=>$data->sangria['monto'],
                        'san_fecha' =>$data->sangria['fecha'],
                        'san_tipo_sangria' => $data->sangria['tipoSangria'],
                        'san_motivo' => $data->sangria['motivo']
                    ]);
                    if ($idSangria > 0) {
                        $message = 'La sangria numero '.''. $idSangria.' fue actualizada correctamente';
                        $status = true; $code = 200;

                    } else {
                        $message = 'Error al actualizar sangria';
                        $status = false; $code = 402 ;
                    }
                }
                DB::commit();
                $exception = new Exepciones($status,$message,$code, []);
                return $exception->SendError();
            } else {
                $exception = new Exepciones($statusCaja[0],$statusCaja[1],403, []);
                return $exception->SendError();
            }
        } catch (QueryException $err) {
            DB::rollBack();
            $exception = new Exepciones(false,$err->getMessage(),$err->getCode(), []);
            return $exception->SendError();
        }
    }
    function Read($params)
    {
        try {
            $listCaja = array();
            $query = DB::table('sangria as s');
            if ($params->fechaDesde && $params->fechaHasta) {
                $query->whereBetween('s.san_fecha', [$params->fechaDesde, $params->fechaHasta]);
            }
            if ($params->caja) {
                $query->where('s.id_caja',$params->caja);
            }
            if ($params->tipoSangria) {
                $query->where('s.san_tipo_sangria',$params->tipoSangria);
            }
            if(!$params->caja && !$params->tipoSangria) {
                $caja = DB::table("caja")->select('*')->get();
            } else {
                $caja = [];
            }
            $query->join('user as us', 's.id_user', '=', 'us.id_user')
                ->join('persona as per','per.id_user', '=', 'us.id_user')
                ->join('caja as ca', 's.id_caja', '=', 'ca.id_caja')
                ->select('s.*', 'per.per_nombre', 'ca.ca_name')
                ->get();
            $result= $query->get();
            array_push($listCaja,['lista'=>$result, 'caja' => $caja]);
            $exception = new Exepciones(true,'lista encontrada',200, $listCaja[0]);
            return $exception->SendError();
        }catch (QueryException $exception) {
            $exception = new Exepciones(false,$exception->getMessage(),$exception->getCode(), []);
            return $exception->SendError();
        }
    }

    function delete($id)
    {
        try {
            if ($id === 0) {
                $message = 'El numero de sangria  '.$id. 'debe ser mayor a 0';
                $status = false;
                $code = 401;
            }
            $idsangria = DB::table('sangria')->where('id_sangria', $id)->first();
            if (empty($idsangria->id_sangria)) {
                $message = 'El numero de sangria  '.$idsangria->id_sangria. 'no existe en nuestra base de datos';
                $status = false;
                $code = 401;
            } else {
                DB::table('sangria')->where('id_sangria', $id)->delete();
                $message = 'La sangria numero '.$id. ' se elimino correctamente';
                $status = true;
                $code = 200;
            }
            $exepciones = new Exepciones($status,$message, $code, []);
            return $exepciones->SendError();
        } catch (QueryException $exception) {
            $exepciones = new Exepciones(false,$exception->getMessage(), $exception->getCode(), []);
            return $exepciones->SendError();
        }
    }

}
