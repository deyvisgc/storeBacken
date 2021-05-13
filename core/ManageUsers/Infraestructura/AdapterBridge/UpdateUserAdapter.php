<?php


namespace Core\ManageUsers\Infraestructura\AdapterBridge;


use Core\ManageUsers\Application\UseCases\UpdateUserUseCase;
use Core\ManageUsers\Domain\Entity\UserEntity;
use Core\ManageUsers\Infraestructura\DataBase\UserRepositoryImpl;

class UpdateUserAdapter
{
    /**
     * @var UserRepositoryImpl
     */
    private UserRepositoryImpl $userRepositoryImpl;

    public function __construct(UserRepositoryImpl $userRepositoryImpl)
    {
        $this->userRepositoryImpl = $userRepositoryImpl;
    }

    public function updateUser(UserEntity $userEntity, $perfil) {
        $user = new UpdateUserUseCase($this->userRepositoryImpl);
        return $user->editUser($userEntity, $perfil);
    }
    function ActualizarPassword($passwordActual,$passwordNueva,$us_usuario, $passwordView) {
        $user = new UpdateUserUseCase($this->userRepositoryImpl);
        return $user->actualizarPassword($passwordActual,$passwordNueva,$us_usuario, $passwordView);
    }
    function ChangeUsuario($usuario) {
        $user = new UpdateUserUseCase($this->userRepositoryImpl);
        return $user->ChangeUsuario($usuario);
    }
    function RecuperarPassword($idUsuario, $passwordNueva,$passwordView) {
        $user = new UpdateUserUseCase($this->userRepositoryImpl);
        return $user->RecuperarPassword($idUsuario, $passwordNueva,$passwordView);
    }
    function ChangeStatus($data) {
        $user = new UpdateUserUseCase($this->userRepositoryImpl);
        return $user->ChangeStatus($data);
    }
}
