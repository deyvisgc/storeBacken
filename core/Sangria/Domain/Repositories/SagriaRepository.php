<?php


namespace Core\Sangria\Domain\Repositories;


use Core\Sangria\Domain\Entity\SangriaEntity;

interface SagriaRepository
{
    public function listSangria();
    public function editSangria(SangriaEntity $sangriaEntity);
    public function createSangria(SangriaEntity $sangriaEntity);
    public function deleteSangria(int $idSangria);

}
