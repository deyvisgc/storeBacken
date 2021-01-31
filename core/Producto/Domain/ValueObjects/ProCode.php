<?php


namespace Core\Producto\Domain\ValueObjects;


class ProCode
{


    private string $code;

    public function __construct(string $code)
 {
     $this->code = $code;
 }
    public function getCode(): string
    {
        return $this->code;
    }

}
