<?php


namespace Core\Traits;


use Illuminate\Support\Facades\DB;

trait QueryTraits
{
    public function Clasehijoxidpadre(int $idpadre)
    {
        return DB::select("select  subclase.clasehijo, subclase.clas_id_clase_superior, subclase.id_clase_producto from
                              (select clas_name as clasehijo ,clas_id_clase_superior, id_clase_producto  from
                              clase_producto where clas_id_clase_superior <> 0) as subclase,
                              clase_producto as cp where cp.id_clase_producto = subclase.clas_id_clase_superior and subclase.clas_id_clase_superior=$idpadre group by cp.clas_name, id_clase_producto");
    }
    public function Clasehijo()
    {
        return DB::select(" select  subclase.clasehijo, subclase.clas_id_clase_superior, subclase.id_clase_producto from
                              (select clas_name as clasehijo ,clas_id_clase_superior, id_clase_producto  from
                              clase_producto where clas_id_clase_superior <> 0) as subclase,
                              clase_producto as cp where cp.id_clase_producto = subclase.clas_id_clase_superior  group by cp.clas_name, id_clase_producto");
    }
    public function ClasePadre()
    {
        return DB::select("select cp.clas_name as clasepadre, cp.id_clase_producto from (select clas_id_clase_superior, clas_status from
                                  clase_producto where clas_id_clase_superior <> 0) as subclase,
                                  clase_producto as cp where cp.id_clase_producto = subclase.clas_id_clase_superior or cp.clas_id_clase_superior = 0 group by cp.clas_name, id_clase_producto");
    }
    public function Padreehijoclase()
    {
        return DB::select("select cp.clas_name as clasepadre,
       subclase.clas_name as clasehijo,
       subclase.clas_status as statushijo,
       cp.clas_status as statuspadre,
       cp.id_clase_producto as idpadre,
       cp.clas_id_clase_superior,
       subclase.id_clase_producto as idhijo
       from
       (select clas_name,clas_id_clase_superior, clas_status,id_clase_producto from
       clase_producto where clas_id_clase_superior <> 0) as subclase,
       clase_producto as cp where cp.id_clase_producto = subclase.clas_id_clase_superior
       order by cp.id_clase_producto asc");
    }
    public function Padreehijoclasexid(int $idpadre)
    {
        return DB::select("select cp.clas_name as clasepadre,
       subclase.clas_name as clasehijo,
       subclase.clas_status as statushijo,
       cp.clas_status as statuspadre,
       cp.id_clase_producto as idpadre,
       cp.clas_id_clase_superior,
       subclase.id_clase_producto as idhijo
       from
       (select clas_name,clas_id_clase_superior, clas_status,id_clase_producto from
       clase_producto where clas_id_clase_superior <> 0) as subclase,
       clase_producto as cp where cp.id_clase_producto = subclase.clas_id_clase_superior and cp.id_clase_producto =$idpadre
       order by cp.id_clase_producto asc");
    }
}
