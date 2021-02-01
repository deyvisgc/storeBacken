<?php


namespace Core\Almacen\Lote\Domain\Entity;



use Core\Almacen\Lote\Domain\ValueObjects\L0TCREATIONDATE;
use Core\Almacen\Lote\Domain\ValueObjects\LOTCODIGO;
use Core\Almacen\Lote\Domain\ValueObjects\LOTEESPIRACIDATE;
use Core\Almacen\Lote\Domain\ValueObjects\LOTNAME;

class LoteEntity
{


    public function __construct(LOTNAME $lotname, LOTCODIGO $lotcodigo,LOTEESPIRACIDATE $loteespiradate,L0TCREATIONDATE $lot_creation_date)
    {

    }

    static function create(LOTNAME $lotname, LOTCODIGO $lotcodigo,LOTEESPIRACIDATE $loteespiradate,L0TCREATIONDATE $lot_creation_date)
    {
        return new self($lotname, $lotcodigo,$loteespiradate,$lot_creation_date);
    }

    static function update(LOTNAME $lotname, LOTCODIGO $lotcodigo,LOTEESPIRACIDATE $loteespiradate,L0TCREATIONDATE $lot_creation_date)
    {
        return new self($lotname, $lotcodigo,$loteespiradate,$lot_creation_date);
    }


}
