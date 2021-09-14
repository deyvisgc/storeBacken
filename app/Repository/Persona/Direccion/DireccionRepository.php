<?php


namespace App\Repository\Persona\Direccion;


use App\Http\Excepciones\Exepciones;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;

class DireccionRepository implements DireccionRepositoryInterface
{

    function getDepartamento($params)
    {
        try {
            $numeroRecnum = $params['numeroRecnum'];
            $cantidadRegistros = $params['cantidadRegistros'];
            $lista = DB::table('ubigeo_peru_departments')
                    ->skip($numeroRecnum)
                    ->take($cantidadRegistros)
                    ->orderBy('id', 'asc')
                    ->get();
            if (count($lista) < $cantidadRegistros) {
                $numberRecnum = 0;
                $noMore = true;
            } else {
                $numberRecnum = (int)$numeroRecnum + count($lista);
                $noMore = false;
            }
            $excepcion = new Exepciones(true,'Departamentos encontrados', 200,['departamento'=>$lista, 'numeroRecnum'=>$numberRecnum,'noMore'=>$noMore]);
            return $excepcion->SendStatus();
        } catch (QueryException $exception) {
            $excepcion = new Exepciones(false,$exception->getMessage(), $exception->getCode(),[]);
            return $excepcion->SendStatus();
        }
    }

    function getProvincia($params)
    {
        try {
            $numeroRecnum = $params['numeroRecnum'];
            $cantidadRegistros = $params['cantidadRegistros'];
            $idDepartamento = $params['id_departamento'];
            $lista = DB::table('ubigeo_peru_provinces')
                        ->where('department_id', $idDepartamento)
                        ->skip($numeroRecnum)
                        ->take($cantidadRegistros)
                        ->orderBy('id', 'asc')
                        ->get();
            if (count($lista) < $cantidadRegistros) {
                $numberRecnum = 0;
                $noMore = true;
            } else {
                $numberRecnum = (int)$numeroRecnum + count($lista);
                $noMore = false;
            }
            $excepcion = new Exepciones(true,'Provincias encontradas', 200,['provincia'=>$lista, 'numeroRecnum'=>$numberRecnum,'noMore'=>$noMore]);
            return $excepcion->SendStatus();
        } catch (QueryException $exception) {
            $excepcion = new Exepciones(false,$exception->getMessage(), $exception->getCode(),[]);
            return $excepcion->SendStatus();
        }
    }

    function getDistrito($params)
    {
        try {
            $numeroRecnum = $params['numeroRecnum'];
            $cantidadRegistros = $params['cantidadRegistros'];
            $idDepartamento = $params['id_departamento'];
            $idProvincia = $params['id_provincia'];
            $lista = DB::table('ubigeo_peru_districts')
                ->where('department_id', $idDepartamento)
                ->where('province_id', $idProvincia)
                ->skip($numeroRecnum)
                ->take($cantidadRegistros)
                ->orderBy('id', 'asc')
                ->get();
            if (count($lista) < $cantidadRegistros) {
                $numberRecnum = 0;
                $noMore = true;
            } else {
                $numberRecnum = (int)$numeroRecnum + count($lista);
                $noMore = false;
            }
            $excepcion = new Exepciones(true,'Distritos encontrados', 200,['distrito'=>$lista, 'numeroRecnum'=>$numberRecnum,'noMore'=>$noMore]);
            return $excepcion->SendStatus();
        } catch (QueryException $exception) {
            $excepcion = new Exepciones(false,$exception->getMessage(), $exception->getCode(),[]);
            return $excepcion->SendStatus();
        }
    }

    function searchDepartamento($texto)
    {
        try {
            $query =  DB::table('ubigeo_peru_departments')
                      ->where('id', 'like', '%'.$texto.'%')
                      ->orWhere('name', 'like', '%'.$texto.'%')
                      ->orderBy('id', 'asc')
                      ->get();
            $ecepciones = new Exepciones(true, 'Informacion Encontrada', 200, ['lista'=> $query, 'cantidad'=> count($query)]);
            return $ecepciones->SendStatus();
        } catch (QueryException $exception) {
            $ecepciones = new Exepciones(false, $exception->getMessage(), $exception->getCode(), []);
            return $ecepciones->SendStatus();
        }
    }

    function searchProvincia($params)
    {
        try {
            $idDepartamento = $params['id_departamento'];
            $texto = $params['texto'];
            $query =  DB::table('ubigeo_peru_provinces')
                      ->where('department_id', $idDepartamento)
                      ->where('name', 'like', '%'.$texto.'%')
                      ->orderBy('id', 'asc')
                      ->get();
            $ecepciones = new Exepciones(true, 'Informacion Encontrada', 200, ['lista'=> $query, 'cantidad'=> count($query)]);
            return $ecepciones->SendStatus();
        } catch (QueryException $exception) {
            $ecepciones = new Exepciones(false, $exception->getMessage(), $exception->getCode(), []);
            return $ecepciones->SendStatus();
        }
    }

    function searchDistrito($params)
    {
        try {
            $idDepartamento = $params['id_departamento'];
            $idProvincia = $params['id_provincia'];
            $texto = $params['texto'];
            $query =  DB::table('ubigeo_peru_districts')
                ->where('department_id', $idDepartamento)
                ->where('province_id', $idProvincia)
                ->where('name', 'like', '%'.$texto.'%')
                ->orderBy('id', 'asc')
                ->get();
            $ecepciones = new Exepciones(true, 'Informacion Encontrada', 200, ['lista'=> $query, 'cantidad'=> count($query)]);
            return $ecepciones->SendStatus();
        } catch (QueryException $exception) {
            $ecepciones = new Exepciones(false, $exception->getMessage(), $exception->getCode(), []);
            return $ecepciones->SendStatus();
        }
    }
}
