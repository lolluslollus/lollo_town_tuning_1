local luadump = require('lollo_building_tuning/luadump')

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
		},
		-- LOLLO TODO activate this mod, then start the game, then press "land use layer": the game freezes.
		runFn = function (settings)
			local mySettings = require('/lollo_building_tuning/settings')

			addFileFilter("construction", filterLevels(mySettings.townBuildingLevelOptions))
			addFileFilter("construction", filterEras(mySettings.townBuildingEraOptions))
			game.config.townMajorStreetAngleRange = mySettings.townMajorStreetAngleRange
			game.config.townDevelopInterval = mySettings.townDevelopInterval

			print('LOLLO game.config.townDevelopInterval = ', game.config.townDevelopInterval)
		end,
	}
end
