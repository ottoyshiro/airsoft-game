class_name WeaponTypes

enum MagazineType {
	Shotgun,
	Rifle,
	Pistol1911,
	PistolGlock
}

static func nome_tipo(tipo: MagazineType) -> String:
	match tipo:
		MagazineType.Shotgun:
			return "Shotgun"
		MagazineType.Rifle:
			return "Rifle"
		MagazineType.Pistol1911:
			return "1911"
		MagazineType.PistolGlock:
			return "Glock"

	return "Desconhecido"
