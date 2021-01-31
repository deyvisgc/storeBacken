<?php


namespace Core\Almacen\Unidad\Domain\Entity;

use Core\Almacen\Unidad\Domain\ValueObjects\UMNAME;
use Core\Almacen\Unidad\Domain\ValueObjects\UMNOMBRECORTO;

class UnidadEntity
{


    /**
     * @var UMNAME
     */
    private UMNAME $UMNAME;
    /**
     * @var UMNOMBRECORTO
     */
    private UMNOMBRECORTO $UMNOMBRECORTO;


    public function __construct(UMNAME $UMNAME, UMNOMBRECORTO $UMNOMBRECORTO)
    {

        $this->UMNAME = $UMNAME;
        $this->UMNOMBRECORTO = $UMNOMBRECORTO;
    }

    static function create(UMNAME $UMNAME, UMNOMBRECORTO $UMNOMBRECORTO)
    {
        return new self($UMNAME, $UMNOMBRECORTO);
    }

    static function update(UMNAME $UMNAME, UMNOMBRECORTO $UMNOMBRECORTO)
    {
        return new self($UMNAME, $UMNOMBRECORTO);
    }

    /**
     * @return UMNAME
     */
    public function UMNAME(): UMNAME
    {
        return $this->UMNAME;
    }

    /**
     * @return UMNOMBRECORTO
     */
    public function UMNOMBRECORTO(): UMNOMBRECORTO
    {
        return $this->UMNOMBRECORTO;
    }
}
