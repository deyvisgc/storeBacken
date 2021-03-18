<?php


namespace Core\Almacen\Lote\Domain\Entity;



use Core\Almacen\Lote\Domain\ValueObjects\L0TCREATIONDATE;
use Core\Almacen\Lote\Domain\ValueObjects\LOTCODIGO;
use Core\Almacen\Lote\Domain\ValueObjects\LOTEESPIRACIDATE;
use Core\Almacen\Lote\Domain\ValueObjects\LOTNAME;

class LoteEntity
{


    /**
     * @var LOTNAME
     */
    private LOTNAME $lotname;
    /**
     * @var LOTCODIGO
     */
    private LOTCODIGO $lotcodigo;
    /**
     * @var LOTEESPIRACIDATE
     */
    private LOTEESPIRACIDATE $loteespiradate;
    /**
     * @var L0TCREATIONDATE
     */
    private L0TCREATIONDATE $lot_creation_date;

    public function __construct(LOTNAME $lotname, LOTCODIGO $lotcodigo, LOTEESPIRACIDATE $loteespiradate, L0TCREATIONDATE $lot_creation_date)
    {

        $this->lotname = $lotname;
        $this->lotcodigo = $lotcodigo;
        $this->loteespiradate = $loteespiradate;
        $this->lot_creation_date = $lot_creation_date;
    }

    /**
     * @return LOTNAME
     */
    public function Lotname(): LOTNAME
    {
        return $this->lotname;
    }

    /**
     * @return LOTCODIGO
     */
    public function Lotcodigo(): LOTCODIGO
    {
        return $this->lotcodigo;
    }

    /**
     * @return LOTEESPIRACIDATE
     */
    public function Loteespiradate(): LOTEESPIRACIDATE
    {
        return $this->loteespiradate;
    }

    /**
     * @return L0TCREATIONDATE
     */
    public function LotCreationDate(): L0TCREATIONDATE
    {
        return $this->lot_creation_date;
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
