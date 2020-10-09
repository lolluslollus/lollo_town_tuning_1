local results = {}

results.townBuildingEraOptions = {
	BuildingsEraA = {
		order = 2,
		type = "boolean",
		default = true,
		value = true,
		name = _("Era A Buildings"),
		description = _("BuildingsEraA"),
	},
	BuildingsEraB = {
		order = 3,
		type = "boolean",
		default = true,
		value = true,
		name = _("Era B Buildings"),
		description = _("BuildingsEraB"),
	},
	BuildingsEraC = {
		order = 4,
		type = "boolean",
		default = true,
		value = true,
		name = _("Era C Buildings"),
		description = _("BuildingsEraC"),
	},
}
results.townBuildingLevelOptions = {
	BuildingsLvl2 = {
		order=2,
		type = "boolean",
		default = true,
		value = true,
		name = _("LVL 2 Buildings"),
		description = _("BuildingsLvl2"),
	},
	BuildingsLvl3 = {
		order=3,
		type = "boolean",
		default = true,
		value = true,
		name = _("LVL 3 Buildings"),
		description = _("BuildingsLvl3"),
	},
	BuildingsLvl4 = {
		order=4,
		type = "boolean",
		default = false,
		value = false,
		name = _("LVL 4 Buildings"),
		description = _("BuildingsLvl4"),
	},
}

results.townBuildingDemandFactor = 0.1 -- default would be 1
results.townBuildingPersonCapacityFactor = 1.0 -- default would be 1
results.townDevelopInterval = 20.0 -- was 60.0
results.townMajorStreetAngleRange = 10.0 -- was 0.0

return results
