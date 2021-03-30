<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ClaseProduct extends Model
{
   protected $table = 'clase_producto';
   protected $primaryKey = 'id_clase_producto';
   public $timestamps = false;
    protected $fillable = [
        'clas_name', 'clas_id_clase_superior','clas_status'
    ];

}
