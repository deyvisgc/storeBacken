<?php


namespace Core\ManageUsers\Domain\Entity;


class UserEntity
{

    private string $userName;
    private string $userPassword;
    private string $userStatus;
    private string $userToken;
    private int $idPersona;
    private int $idRol;
    private int $idUser;

    public function __construct(int $idUser, string $userName, string $userPassword, string $userStatus, string $userToken, int $idPersona, int $idRol)
    {
        $this->userName = $userName;
        $this->userPassword = $userPassword;
        $this->userStatus = $userStatus;
        $this->userToken = $userToken;
        $this->idPersona = $idPersona;
        $this->idRol = $idRol;
        $this->idUser = $idUser;
    }

    /**
     * @return int
     */
    public function getIdRol(): int
    {
        return $this->idRol;
    }

    /**
     * @param int $idRol
     */
    public function setIdRol(int $idRol): void
    {
        $this->idRol = $idRol;
    }

    /**
     * @return int
     */
    public function getIdPersona(): int
    {
        return $this->idPersona;
    }

    /**
     * @param int $idPersona
     */
    public function setIdPersona(int $idPersona): void
    {
        $this->idPersona = $idPersona;
    }

    /**
     * @return string
     */
    public function getUserName(): string
    {
        return $this->userName;
    }

    /**
     * @param string $userName
     */
    public function setUserName(string $userName): void
    {
        $this->userName = $userName;
    }

    /**
     * @return string
     */
    public function getUserPassword(): string
    {
        return $this->userPassword;
    }

    /**
     * @param string $userPassword
     */
    public function setUserPassword(string $userPassword): void
    {
        $this->userPassword = $userPassword;
    }

    /**
     * @return string
     */
    public function getUserStatus(): string
    {
        return $this->userStatus;
    }

    /**
     * @param string $userStatus
     */
    public function setUserStatus(string $userStatus): void
    {
        $this->userStatus = $userStatus;
    }

    /**
     * @return string
     */
    public function getUserToken(): string
    {
        return $this->userToken;
    }

    /**
     * @param string $userToken
     */
    public function setUserToken(string $userToken): void
    {
        $this->userToken = $userToken;
    }

    /**
     * @return int
     */
    public function getIdUser(): int
    {
        return $this->idUser;
    }

    /**
     * @param int $idUser
     */
    public function setIdUser(int $idUser): void
    {
        $this->idUser = $idUser;
    }

    public function toArray(): array {
        return [
            'id_user' => $this->getIdUser(),
            'us_name' => $this->getUserName(),
            'us_passwor' => $this->getUserPassword(),
            'us_status' => $this->getUserStatus(),
            'us_token' => $this->getUserToken(),
            'id_persona' => $this->getIdPersona(),
            'id_rol' => $this->getIdRol(),
        ];
    }

}
