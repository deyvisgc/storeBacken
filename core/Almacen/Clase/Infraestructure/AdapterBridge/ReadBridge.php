<?php


namespace Core\Almacen\Clase\Infraestructure\AdapterBridge;


use Core\Almacen\Clase\Aplication\UseCases\ReadCase;
use Core\Almacen\Clase\Infraestructure\DataBase\ClaseSql;
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
}
