<?php


namespace App\Http\Excepciones;

class Exepciones
{
    private string $Message;
    private int $Codigo;
    private $Status;
    private $data;

    public function __construct($Status, string $Message, int $Codigo, $data)
    {

        $this->Status = $Status;
        $this->Message = $Message;
        $this->Codigo = $Codigo;
        $this->data = $data;
    }
    public function SendError() {
        $array = ['status' => $this->Status, 'message' => $this->Message, 'codigo' =>  $this->Codigo, 'data' => $this->data];
        return $array;
    }
}
