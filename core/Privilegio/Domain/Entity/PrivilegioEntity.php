<?php


namespace Core\Privilegio\Domain\Entity;


class PrivilegioEntity
{
    private string $priNombre;
    private string $priAcces;
    private string $priGroup;
    private string $priOrden;
    private string $priStatus;
    private string $priIcon;

    public function __construct(
        string $priNombre,
        string $priAcces,
        string $priGroup,
        string $priOrden,
        string $priStatus,
        string $priIcon)
    {
        $this->priNombre = $priNombre;
        $this->priAcces = $priAcces;
        $this->priGroup = $priGroup;
        $this->priOrden = $priOrden;
        $this->priStatus = $priStatus;
        $this->priIcon = $priIcon;
    }

    /**
     * @return string
     */
    public function getPriNombre(): string
    {
        return $this->priNombre;
    }

    /**
     * @param string $priNombre
     */
    public function setPriNombre(string $priNombre): void
    {
        $this->priNombre = $priNombre;
    }

    /**
     * @return string
     */
    public function getPriAcces(): string
    {
        return $this->priAcces;
    }

    /**
     * @param string $priAcces
     */
    public function setPriAcces(string $priAcces): void
    {
        $this->priAcces = $priAcces;
    }

    /**
     * @return string
     */
    public function getPriGroup(): string
    {
        return $this->priGroup;
    }

    /**
     * @param string $priGroup
     */
    public function setPriGroup(string $priGroup): void
    {
        $this->priGroup = $priGroup;
    }

    /**
     * @return string
     */
    public function getPriOrden(): string
    {
        return $this->priOrden;
    }

    /**
     * @param string $priOrden
     */
    public function setPriOrden(string $priOrden): void
    {
        $this->priOrden = $priOrden;
    }

    /**
     * @return string
     */
    public function getPriStatus(): string
    {
        return $this->priStatus;
    }

    /**
     * @param string $priStatus
     */
    public function setPriStatus(string $priStatus): void
    {
        $this->priStatus = $priStatus;
    }

    /**
     * @return string
     */
    public function getPriIcon(): string
    {
        return $this->priIcon;
    }

    /**
     * @param string $priIcon
     */
    public function setPriIcon(string $priIcon): void
    {
        $this->priIcon = $priIcon;
    }

    public function toArray(): array
    {
        return [
            'pri_nombre' => $this->priNombre,
            'pri_acces' => $this->priAcces,
            'pri_group' => $this->priGroup,
            'pri_orden' => $this->priOrden,
            'pri_status' => $this->priStatus,
            'pri_ico' => $this->priIcon,
        ];
    }


}
