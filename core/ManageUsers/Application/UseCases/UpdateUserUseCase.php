<?php


namespace Core\ManageUsers\Application\UseCases;


use Core\ManageUsers\Domain\Entity\UserEntity;
use Core\ManageUsers\Domain\Repositories\UserRepository;

class UpdateUserUseCase
{
    /**
     * @var UserRepository
     */
    private UserRepository $userRepository;

    public function __construct(UserRepository $userRepository)
    {
        $this->userRepository = $userRepository;
    }

     function editUser(UserEntity $userEntity, $perfil)
    {
        return $this->userRepository->editUser($userEntity, $perfil);
    }
     function actualizarPassword($passwordActual,$passwordNueva,$us_usuario, $passwordView)
    {
        return $this->userRepository->updatePassword($passwordActual,$passwordNueva,$us_usuario, $passwordView);
    }
    function ChangeUsuario($usuario) {
        return $this->userRepository->ChangeUsuario($usuario);
    }
    function RecuperarPassword($idUsuario, $passwordNueva,$passwordView) {
        return $this->userRepository->RecuperarPassword($idUsuario, $passwordNueva,$passwordView);
    }
    function ChangeStatus($data) {
        return $this->userRepository->ChangeStatus($data);
    }
}
