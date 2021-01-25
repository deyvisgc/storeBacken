<?php


namespace Core\Rol\Domain\Entity;


class RolEntity
{
    private string $rolName;
    private string $rolStatus;
    private int $idRol;

    public function __construct(
        string $rolName,
        string $rolStatus,
        int $idRol
    )
    {
        $this->rolName = $rolName;
        $this->rolStatus = $rolStatus;
        $this->idRol = $idRol;
    }

    /**
     * @return string
     */
    public function getRolName(): string
    {
        return $this->rolName;
    }

    /**
     * @param string $rolName
     */
    public function setRolName(string $rolName): void
    {
        $this->rolName = $rolName;
    }

    /**
     * @return string
     */
    public function getRolStatus(): string
    {
        return $this->rolStatus;
    }

    /**
     * @param string $rolStatus
     */
    public function setRolStatus(string $rolStatus): void
    {
        $this->rolStatus = $rolStatus;
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

    public function toArray(): array
    {
        return [
            'id_rol' => $this->idRol,
            'rol_name' => $this->rolName,
            'rol_status' => $this->rolStatus,
        ];
    }
}
