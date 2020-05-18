-- local luadump = require('luadump')

local townBuildingEraOptions = {
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
local townBuildingLevelOptions = {
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
local townMajorStreetAngleRange = 10.0 -- .0

function data()
	local filterLevels = function(options)
		if options.BuildingsLvl2 == nil then
			error("options empty")
		end
		return function(fileName, data)
			if data.type == "TOWN_BUILDING" then
				-- print('LOLLO filename = ', fileName, 'level = ', data.townBuildingParams.level)
				-- removing level 1 buildings leads to crash:  c:\build\tpf2_steam\src\game\procedural\buildingtyperep.cpp:63: class std::vector<class std::basic_string<char,struct std::char_traits<char>,class std::allocator<char> >,class std::allocator<class std::basic_string<char,struct std::char_traits<char>,class std::allocator<char> > > > __cdecl `anonymous-namespace'::GetCandidates(const class std::unordered_map<class std::basic_string<char,struct std::char_traits<char>,class std::allocator<char> >,struct BuildingType,struct std::hash<class std::basic_string<char,struct std::char_traits<char>,class std::allocator<char> > >,struct std::equal_to<class std::basic_string<char,struct std::char_traits<char>,class std::allocator<char> > >,class std::allocator<struct std::pair<class std::basic_string<char,struct std::char_traits<char>,class std::allocator<char> > const ,struct BuildingType> > > &,const class ConstructionRep *,enum LandUseType,int,int): Assertion `false' failed.
				if data.townBuildingParams.level == 2 and options.BuildingsLvl2.value == false then
					return false
				elseif data.townBuildingParams.level == 3 and options.BuildingsLvl3.value == false then
					return false
				elseif data.townBuildingParams.level == 4 and options.BuildingsLvl4.value == false then
					return false
				end
			end
			return true
		end
	end
	
	local filterEras = function(options)
		if options.BuildingsEraA==nil then
			error("options empty")
		end
		-- townBuildingUtil does:
		-- local ab = 1920
		-- local bc = 1990
		-- local availability = {
		-- 	yearFrom = era == "A" and 0 or (era == "B" and ab or bc),
		-- 	yearTo = era == "A" and ab or (era == "B" and bc or 0)
		-- }
		-- this is the inverse:
		local function isEraFunc(yearFrom, yearTo)
			return function(availability)
				if availability.yearFrom == yearFrom and availability.yearTo == yearTo then
					return true
				else
					return false
				end
			end
		end
		local isEraA = isEraFunc(0, 1920)
		local isEraB = isEraFunc(1920, 1990)
		local isEraC = isEraFunc(1990 ,0)

		return function(fileName, data)
			if data.type=="TOWN_BUILDING" then
				-- print('LOLLO filename = ', fileName, 'availability = ', data.availability)
				if options.BuildingsEraA == false and isEraA(data.availability) then
					return false
				elseif options.BuildingsEraB == false and isEraB(data.availability) then
					return false
				elseif options.BuildingsEraC == false and isEraC(data.availability) then
					return false
				end
				-- fallback, probably useless
				data.availability.yearFrom = 0
				data.availability.yearTo = 0
			end
			return true
		end
	end
	

	return {
		info = {
			minorVersion = 0,
			severityAdd = "NONE",
			severityRemove = "NONE",
			name = _("NAME"),
			description = _("DESC"),
			tags = { "Script Mod", "Town Building" },
			authors = {
				{
					name = "Lollus",
					role = 'CREATOR',
				},
				{
					name = "Sparky",
					role = 'CREATOR',
				},
				{
					name = "VacuumTube",
					role = "CREATOR",
				},
			},
			-- categories = {
			-- 	{ key = "one", name = _("One") },
			-- 	{ key = "two", name = _("Two") },
			-- },
			-- settings = {
			-- 	-- format: category = { list of key/name pairs }
			-- 	one = { { "one1", _("One 1") }, { "one2", _("One 2") } },
			-- 	two = { { "two1", _("Two 1") }, { "two2", _("Two 2") } },
			-- },
			-- options = {
			-- 	-- format: category = { list of key/name pairs }
			-- 	one = { { "one1", _("One 1") }, { "one2", _("One 2") } },
			-- 	two = { { "two1", _("Two 1") }, { "two2", _("Two 2") } },
			-- },
		},
		-- options to show in the advanced game settings menu (optional)
		-- The basic process is as follows: the options from all active mods 
		-- are collected and presented to the user. 
		-- The user can then select an entry in each category. 
		-- When the game starts, this configuration (table/dictionary) 
		-- is passed to the function runFn (parameter settings), 
		-- which can then act accordingly. 
		-- The initial set of options (and the base run function) 
		-- is defined in res\config\base_mod.lua.
		-- LOLLO NOTE these values never pull, neither options nor settings nor categories
		categories = {
			{ key = "one", name = _("One") },
			{ key = "two", name = _("Two") },
		},
		options = {
			-- format: category = { list of key/name pairs }
			one = { { "one1", _("One 1") }, { "one2", _("One 2") } },
			two = { { "two1", _("Two 1") }, { "two2", _("Two 2") } },
		},
		settings = {
			-- format: category = { list of key/name pairs }
			one = { { "one1", _("One 1") }, { "one2", _("One 2") } },
			two = { { "two1", _("Two 1") }, { "two2", _("Two 2") } },
		},
		runFn = function (settings)
			-- settings = {
			-- 	climate = "temperate",
			-- 	environment = "temperate",
			-- 	nameList = "europe",
			-- 	vehicles = "europe"
			--   }
			-- print('LOLLO settings = ')
			-- luadump(true)(settings)
			addFileFilter("construction", filterLevels(townBuildingLevelOptions))
			addFileFilter("construction", filterEras(townBuildingEraOptions))
			game.config.townMajorStreetAngleRange = townMajorStreetAngleRange
		end,
	}
end
