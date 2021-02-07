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
    public function __invoke()
    {
        $readcase= new ReadCase($this->clase);
        return $readcase->__invoke();
    }
    public function __invokexid(int $id)
    {
        $readcase= new ReadCase($this->clase);
        return $readcase->__invokexid($id);
    }
    public function __clasesuperior()
    {
        $readcase= new ReadCase($this->clase);
        return $readcase->clasesuperior();
    }
    public function __getclaserecursiva()
    {
        $readcase= new ReadCase($this->clase);
        return $readcase->claserecursiva();
    }
    public function __Obtenerclasexid($idpadre) {
        $readcase= new ReadCase($this->clase);
        return $readcase->Obtenerclasexid($idpadre);
    }
    public function __viewchild($idpadre) {
        $readcase= new ReadCase($this->clase);
        return $readcase->viewchild($idpadre);
    }
}
