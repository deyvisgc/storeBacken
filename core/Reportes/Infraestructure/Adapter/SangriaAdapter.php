<?php


namespace Core\Reportes\Infraestructure\Adapter;

use Core\Reportes\Application\Sangria\AddSangriaUseCase;
use Core\Reportes\Application\Sangria\DeleteSangriaUseCase;
use Core\Reportes\Application\Sangria\ReadSangriaUseCase;
use Core\Reportes\Domain\SangriaRepository;
use Core\Reportes\Infraestructure\Sql\SangriaSql;

class SangriaAdapter
{


    /**
     * @var SangriaSql
     */
    private SangriaSql $sangriaSql;

    public function __construct(SangriaSql $sangriaSql)
    {


        $this->sangriaSql = $sangriaSql;
    }
     function AddSangria($sangria)
    {
        $addcase = new AddSangriaUseCase($this->sangriaSql);
        return  $addcase->AddSangria($sangria);
    }
    function getSangria($params) {
     $readcase = new ReadSangriaUseCase($this->sangriaSql);
     return $readcase->Read($params);
    }
    function deleteSangria($request) {
        $id = $request['id'];
        $readcase = new DeleteSangriaUseCase($this->sangriaSql);
        return $readcase->deleteSangria($id);
    }
}
