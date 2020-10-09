function data()
	local _mySettings = require('/lollo_building_tuning/settings')

	local function constructionCallback(fileName, data)
			-- alter the capacitry of all town buildings
		if (data.type ~= "TOWN_BUILDING") or not(data.updateFn) then return data end
-- print('THREE')
		local originalUpdateFn = data.updateFn
		data.updateFn = function(params)
			local result = originalUpdateFn(params)
			if not(result) then return result end
print('construction.updateFn starting for TOWN_BUILDING with filename =', fileName, 'result = ')
debugPrint(result)
print('params =')
debugPrint(params)
-- local sampleResult = {
-- 	personCapacity = {
-- 		capacity = 4,
-- 		type = "COMMERCIAL", -- "RESIDENTIAL" "INDUSTRIAL"
-- 	},
-- 	rule = { -- only commercial and industrial have this
-- 		capacity = 1,
-- 		consumptionFactor = 1.2,
-- 		input = {
-- 			{ 1, },
-- 		},
-- 		output = { },
-- 	},
-- }
			if result.rule then
				-- LOLLO TODO this needs testing
				print('result.rule.capacity before =', result.rule.capacity)
				print('result.rule.consumptionFactor before =', result.rule.consumptionFactor)
				-- this was copied from yeol senseless
				-- result.rule.capacity = (result.rule.capacity + math.random() * 1.5) * _mySettings.townBuildingDemandFactor
				-- this may increase the amount of industrial buildings
				-- result.rule.capacity = math.ceil(result.rule.capacity * _mySettings.townBuildingDemandFactor)
				-- this should reduce the amount of cargo required
				result.rule.consumptionFactor = result.rule.consumptionFactor * _mySettings.townBuildingDemandFactor
				print('result.rule.capacity after =', result.rule.capacity)
				print('result.rule.consumptionFactor before =', result.rule.consumptionFactor)
			end
			if result.personCapacity then
				print('result.personCapacity.capacity before =', result.personCapacity.capacity)
				result.personCapacity.capacity = math.ceil(result.personCapacity.capacity * _mySettings.townBuildingPersonCapacityFactor)
				print('result.personCapacity.capacity after =', result.personCapacity.capacity)
			end
			return result
		end

		return data
	end

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
		runFn = function (settings)
			-- local mySettings = require('/lollo_building_tuning/settings')

			addFileFilter("construction", filterLevels(_mySettings.townBuildingLevelOptions))
			addFileFilter("construction", filterEras(_mySettings.townBuildingEraOptions))
			addModifier("loadConstruction", constructionCallback)
			game.config.townMajorStreetAngleRange = _mySettings.townMajorStreetAngleRange
			game.config.townDevelopInterval = _mySettings.townDevelopInterval
			-- game.config.animal.populationDensityMultiplier = 0.20 -- was 1 dumps

			if game.config.settings then
				game.config.settings.geometryQualityOptions = {
					-- { viewNearFar = { 4.0, 5000.0 }, fogStartEndFarPerc = { .45, 1.0 }, lodDistanceScaling = .5 },		-- Low original
					{ viewNearFar = { 4.0, 4000.0 }, fogStartEndFarPerc = { .45, 1.0 }, lodDistanceScaling = .25 },		-- Low
					{ viewNearFar = { 4.0, 6000.0 }, fogStartEndFarPerc = { .33, 1.0 }, lodDistanceScaling = .75 },		-- Medium
					{ viewNearFar = { 4.0, 7500.0 }, fogStartEndFarPerc = { .25, 1.0 }, lodDistanceScaling = 1.0 },		-- High
					{ viewNearFar = { 4.0, 15000.0 }, fogStartEndFarPerc = { .125, 1.0 }, lodDistanceScaling = 10 },	-- Camera tool
					{ viewNearFar = { 0.5, 5000.0 }, fogStartEndFarPerc = { 1.0, 1.0 }, lodDistanceScaling = 1.0 },		-- Cockpit view
				}
			end

			print('LOLLO game.config.townDevelopInterval = ', game.config.townDevelopInterval)
		end,
	}
end
