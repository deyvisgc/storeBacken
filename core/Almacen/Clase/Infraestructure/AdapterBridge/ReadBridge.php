<?php


namespace Core\Almacen\Clase\Infraestructure\AdapterBridge;


use Core\Almacen\Clase\Aplication\UseCases\ReadCase;
use Core\Almacen\Clase\Infraestructure\DataBase\ClaseSql;
use Illuminate\Http\Request;

class ReadBridge
{


    /**
     * @var ClaseSql
     */
    private ClaseSql $clase;

    public function __construct(ClaseSql $claseSql)
    {

        $this->clase = $claseSql;
    }
    function getCategoria($params)
    {
        $readcase= new ReadCase($this->clase);
        return $readcase->getCategoria($params);
    }
    function searchCategoria($params) {
        $readcase= new ReadCase($this->clase);
        return $readcase->searchCategoria($params);
    }
    function editCategory($id) {
        $readcase= new ReadCase($this->clase);
        return $readcase->editCategory($id);
    }
    function editSubcate($idpadre) {
        $readcase= new ReadCase($this->clase);
        return $readcase->editSubcate($idpadre);
    }
}
