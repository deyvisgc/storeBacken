<?php


namespace Core\Reportes\Domain;


interface SangriaRepository
{
  function AddSangria($sangria);
  function Read($params);
}
