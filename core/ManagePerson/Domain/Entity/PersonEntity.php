<?php


namespace Core\ManagePerson\Domain\Entity;


class PersonEntity
{


    private ?int $idPersona;
    private ?string $perName;
    private ?string $perLastName;
    private ?string $perAddress;
    private ?string $perPhone;
    private ?string $perType;
    private ?string $perTypeDocument;
    private ?string $perDocNumber;
    private ?string $razonSocial;
    public function __construct(?int $idPersona, ?string $perName, ?string $perLatName, ?string $perAddress, ?string $perPhone, ?string $perType, ?string $perTypeDocument, ?string $perDocNumber, ?string $razonSocial)
    {
        $this->idPersona = $idPersona;
        $this->perName = $perName;
        $this->perLastName = $perLatName;
        $this->perAddress = $perAddress;
        $this->perPhone = $perPhone;
        $this->perType = $perType;
        $this->perTypeDocument = $perTypeDocument;
        $this->perDocNumber = $perDocNumber;
        $this->razonSocial = $razonSocial;
    }

    /**
     * @return string
     */
    public function getRazonSocial(): ?string
    {
        return $this->razonSocial;
    }

    /**
     * @param string $razonSocial
     */
    public function setRazonSocial(string $razonSocial): void
    {
        $this->razonSocial = $razonSocial;
    }

    /**
     * @return string
     */
    public function getPerName(): ?string
    {
        return $this->perName;
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
     * @param string $perName
     */
    public function setPerName(string $perName): void
    {
        $this->perName = $perName;
    }

    /**
     * @return string
     */
    public function getPerLastName(): ?string
    {
        return $this->perLastName;
    }

    /**
     * @param string $perLastName
     */
    public function setPerLastName(string $perLastName): void
    {
        $this->perLastName = $perLastName;
    }

    /**
     * @return string
     */
    public function getPerAddress(): ?string
    {
        return $this->perAddress;
    }

    /**
     * @param string $perAddress
     */
    public function setPerAddress(string $perAddress): void
    {
        $this->perAddress = $perAddress;
    }

    /**
     * @return string
     */
    public function getPerPhone(): ?string
    {
        return $this->perPhone;
    }

    /**
     * @param string $perPhone
     */
    public function setPerPhone(string $perPhone): void
    {
        $this->perPhone = $perPhone;
    }

    /**
     * @return string
     */
    public function getPerType(): ?string
    {
        return $this->perType;
    }

    /**
     * @param string $perType
     */
    public function setPerType(string $perType): void
    {
        $this->perType = $perType;
    }

    /**
     * @return string
     */
    public function getPerTypeDocument(): ?string
    {
        return $this->perTypeDocument;
    }

    /**
     * @param string $perTypeDocument
     */
    public function setPerTypeDocument(string $perTypeDocument): void
    {
        $this->perTypeDocument = $perTypeDocument;
    }

    /**
     * @return string
     */
    public function getPerDocNumber(): ?string
    {
        return $this->perDocNumber;
    }

    /**
     * @param string $perDocNumber
     */
    public function setPerDocNumber(string $perDocNumber): void
    {
        $this->perDocNumber = $perDocNumber;
    }

    public function toArray(): array {
        return [
            'per_nombre' => $this->getPerName(),
            'per_apellido' => $this->getPerLastName(),
            'per_direccion' => $this->getPerAddress(),
            'per_celular' => $this->getPerPhone(),
            'per_tipo_documento' => $this->getPerTypeDocument(),
            'per_numero_documento' => $this->getPerDocNumber(),
            'per_razon_social' =>$this->getRazonSocial()
        ];
    }
    public function toArrayPerfil(): array {
        return [
            'per_nombre' => $this->getPerName(),
            'per_apellido' => $this->getPerLastName(),
            'per_direccion' => $this->getPerAddress(),
            'per_celular' => $this->getPerPhone(),
            'per_numero_documento' => $this->getPerDocNumber()
        ];
    }
}
