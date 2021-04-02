<?php


namespace Core\Reportes\Application\Sangria;


use Core\Reportes\Domain\SangriaRepository;

class AddSangriaUseCase
{
    /**
     * @var SangriaRepository
     */
    private SangriaRepository $repository;

    /**
     * AddSangriaUseCase constructor.
     * @param SangriaRepository $repository
     */
    public function __construct(SangriaRepository $repository)
  {
      $this->repository = $repository;
  }
  function AddSangria($sangria) {
   return $this->repository->AddSangria($sangria);
  }
}
