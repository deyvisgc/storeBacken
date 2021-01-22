<?php


namespace Core\RegistroSanitario\Domain\ValueObjects;


class IdRegistroSanitario
{
    /**
     * @var int
     */
    private $idRegistroSanitario;

    public function __construct(int $idRegistroSanitario)
    {

        $this->idRegistroSanitario = $idRegistroSanitario;
    }

    /**
     * @return int
     */
    public function getIdRegistroSanitario(): int
    {
        return $this->idRegistroSanitario;
    }

    /**
     * @param int $idRegistroSanitario
     */
    public function setIdRegistroSanitario(int $idRegistroSanitario): void
    {
        $this->idRegistroSanitario = $idRegistroSanitario;
    }

}
