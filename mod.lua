-- local arrayUtils = require('lollo_town_tuning.arrayUtils')
local commonData = require('lollo_town_tuning.commonData')
local logger = require('lollo_town_tuning.logger')
local modSettings = require('lollo_town_tuning.settings')
local townBuildingUtilOverride = require('lollo_town_tuning.townBuildingUtilOverride')

function data()
	local function loadConstructionFunc(fileName, data)
		-- alter properties of all buildings in all towns
		-- this fires for every instance of a building, but it does not contain instance-specific data,
		-- such as the building town or location.
		if not(data) or (data.type ~= 'TOWN_BUILDING') or (type(data.updateFn) ~= 'function') then return data end

		-- LOLLO TODO do we need this?
		if type(data.upgradeFn) ~= 'function' then
			data.upgradeFn = function(_) end
		end

		local originalUpdateFn = data.updateFn
		data.updateFn = function(params)
			local result = originalUpdateFn(params)
			if not(result) then return result end

--[[ 			
			if logger.getIsExtendedLog() then
				local _testBuildingFileNameSegment = 'era_b/com_1_1x2_02.con' -- 'era_b/com_1_4x4_04.con'

				-- local sampleResult = {
				-- 	personCapacity = {
				-- 		capacity = 4,
				-- 		type = 'COMMERCIAL', -- 'RESIDENTIAL' 'INDUSTRIAL'
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

				logger.print('construction.updateFn starting for TOWN_BUILDING with filename =', fileName)
				if fileName:find(_testBuildingFileNameSegment) then
					logger.print('result =') logger.debugPrint(result)
					logger.print('data =') logger.debugPrint(data)
					logger.print('params =') logger.debugPrint(arrayUtils.cloneDeepOmittingFields(params, {'state'}))
				end
			end
]]

			local common = commonData.get()
			if result.rule then
				-- LOLLO NOTE how do I find out where a construction is? There seems to be no way.
				-- So, capacity etc changes will affect all towns. COnvenient but slow.
				-- logger.print('result.rule.capacity before =', result.rule.capacity)
				-- logger.print('result.rule.consumptionFactor before =', result.rule.consumptionFactor)
				-- logger.print('(common.capacityFactor or 1.0) =', (common.capacityFactor or 1.0))
				-- logger.print('common.consumptionFactor or 1.0 =', common.consumptionFactor or 1.0)
				result.rule.capacity = math.ceil(result.rule.capacity * (common.capacityFactor or 1.0))
				result.rule.consumptionFactor = common.consumptionFactor or 1.0
				-- logger.print('result.rule.capacity after =', result.rule.capacity)
				-- logger.print('result.rule.consumptionFactor after =', result.rule.consumptionFactor)
			end
			if result.personCapacity then
				-- if fileName:find(_testBuildingFileNameSegment) then
				-- 	logger.print('result.personCapacity.capacity before =', result.personCapacity.capacity)
				-- end
				result.personCapacity.capacity = math.ceil(result.personCapacity.capacity * (common.personCapacityFactor or 1.0))
				-- if fileName:find(_testBuildingFileNameSegment) then
				-- 	logger.print('params.capacity =', params.capacity)
				-- end
				-- if fileName:find(_testBuildingFileNameSegment) then
				-- 	logger.print('result.personCapacity.capacity after =', result.personCapacity.capacity)
				-- end
			end

			return result
		end -- end of updateFn

		return data
	end

	local filterOutSkyscrapersFunc = function(fileName, data)
		if data and data.type == 'TOWN_BUILDING' then
			if data.townBuildingParams
			and data.townBuildingParams.level == 4
			and (data.townBuildingParams.landUseType == 'RESIDENTIAL'
				or data.townBuildingParams.landUseType == 'COMMERCIAL') then
				-- logger.print('LOLLO filtering out filename = ', fileName, 'level = ', data.townBuildingParams.level)
				-- LOLLO NOTE removing level 1 buildings leads to crash:
				-- c:\build\tpf2_steam\src\game\procedural\buildingtyperep.cpp:63:
				-- class std::vector<class std::basic_string<char,struct std::char_traits<char>,class std::allocator<char> >,class std::allocator<class std::basic_string<char,struct std::char_traits<char>,class std::allocator<char> > > > __cdecl `anonymous-namespace'::GetCandidates(const class std::unordered_map<class std::basic_string<char,struct std::char_traits<char>,class std::allocator<char> >,struct BuildingType,struct std::hash<class std::basic_string<char,struct std::char_traits<char>,class std::allocator<char> > >,struct std::equal_to<class std::basic_string<char,struct std::char_traits<char>,class std::allocator<char> > >,class std::allocator<struct std::pair<class std::basic_string<char,struct std::char_traits<char>,class std::allocator<char> > const ,struct BuildingType> > > &,const class ConstructionRep *,enum LandUseType,int,int): Assertion `false' failed.
				return false
			end
		end
		return true
	end

	return {
		info = {
			minorVersion = 9,
			severityAdd = 'NONE',
			severityRemove = 'NONE',
			name = _('ModName'),
			description = _('ModDesc'),
			tags = { 'Performance', 'Script Mod', 'Town Building' },
			authors = {
				{
					name = 'Lollus',
					role = 'CREATOR',
				},
			},
			-- LOLLO NOTE these params must be declared directly here, references to other includes may dump.
			-- whenever you amend or add something, make sure to keep their counterparts up to date in settings.lua
			params = {
                {
                    key = 'noSkyscrapers',
                    name = _('NO_SKYSCRAPERS'),
                    values = { _('No'), _('Yes'), },
					defaultIndex = 1,
                },
				{
                    key = 'oldBuildingsInNewEras',
                    name = _('OLD_BUILDINGS_IN_NEW_ERAS'),
                    values = { _('No'), _('Yes'), },
                },
				{
                    key = 'eraBStartYear',
                    name = _('ERA_B_START_YEAR'),
					values = {'1920 (default)', '1850', '1900', '1950', '1980', _('NEVER')},
                },
				{
                    key = 'eraCStartYear',
                    name = _('ERA_C_START_YEAR'),
					values = {'1980 (default)', '1850', '1900', '1920', '1950', _('NEVER')},
                },
                {
                    key = 'noSquareCrossings',
                    name = _('NO_SQUARE_CROSSINGS'),
                    values = { _('No'), _('Yes'), },
					defaultIndex = 1,
                },
                {
                    key = 'fasterLowGeometry',
                    name = _('FASTER_LOW_GEOMETRY'),
                    values = { _('No'), _('Yes'), },
					defaultIndex = 1,
                },
                {
                    key = 'fasterTownDevelopInterval',
                    name = _('FASTER_TOWN_DEVELOP_INTERVAL'),
                    values = { _('No'), _('Yes'), },
					defaultIndex = 1,
                },
				{
					key = 'simPersonDestinationRecomputationProbability',
					name = _('DESTINATION_RECOMPUTATION_PROBABILITY'),
					values = { '--', '-', '0', '+', '++' },
					defaultIndex = 2,
				},
            },
		},
		runFn = function (settings, modParams)
			-- LOLLO NOTE the game disallows global variables in init.lua
			-- unless I initialise them in runFn
			-- and it does not share them across states anyway
            -- _G.LOLLO_TOWN_TUNING = {
            --     capacityFactor = commonData.defaultCapacityFactor,
            --     consumptionFactor = commonData.defaultConsumptionFactor,
            --     personCapacityFactor = commonData.defaultPersonCapacityFactor,
            -- } -- init global var

			modSettings.setModParamsFromRunFn(modParams)

			if modSettings.getModParamFromRunFn('noSkyscrapers') == 1 then
				addFileFilter('construction', filterOutSkyscrapersFunc)
			end
			addModifier('loadConstruction', loadConstructionFunc)
			-- useless
			-- addModifier('loadConstructionMenu', loadConstructionMenuFunc)
			-- addModifier('loadScript', loadScriptFunc)
			-- addModifier('loadGameScript', loadGameScriptFunc)

			if (modSettings.getModParamFromRunFn('eraBStartYear') ~= modSettings.defaultParams.eraBStartYear
			or modSettings.getModParamFromRunFn('eraCStartYear') ~= modSettings.defaultParams.eraCStartYear
			or modSettings.getModParamFromRunFn('oldBuildingsInNewEras') ~= modSettings.defaultParams.oldBuildingsInNewEras)
			then
				townBuildingUtilOverride(
					modSettings.paramValueNumbers.eraBStartYear[modSettings.getModParamFromRunFn('eraBStartYear') + 1],
					modSettings.paramValueNumbers.eraCStartYear[modSettings.getModParamFromRunFn('eraCStartYear') + 1],
					modSettings.getModParamFromRunFn('oldBuildingsInNewEras') == 1
				)
			end

			if modSettings.getModParamFromRunFn('noSquareCrossings') == 1 then
				game.config.townMajorStreetAngleRange = 10.0 -- default is 0.0
				game.config.townInitialMajorStreetAngleRange = 10.0 -- same but only active during first creation of a town
			end
			if modSettings.getModParamFromRunFn('fasterTownDevelopInterval') == 1 then
				game.config.townDevelopInterval = 20.0 -- default is 60.0
			end
			-- game.config.animal.populationDensityMultiplier = 0.20 -- was 1 dumps

			if modSettings.getModParamFromRunFn('fasterLowGeometry') == 1 then
				if game.config and game.config.settings then
					game.config.settings.geometryQualityOptions = {
						-- { viewNearFar = { 4.0, 5000.0 }, fogStartEndFarPerc = { 0.45, 1.0 }, lodDistanceScaling = 0.5 },		-- Low original
						{ viewNearFar = { 4.0, 3000.0 }, fogStartEndFarPerc = { 0.45, 1.0 }, lodDistanceScaling = 0.40 },		-- Low
						-- { viewNearFar = { 4.0, 6000.0 }, fogStartEndFarPerc = { 0.33, 1.0 }, lodDistanceScaling = 0.75 },	-- Medium original
						{ viewNearFar = { 4.0, 5000.0 }, fogStartEndFarPerc = { 0.33, 1.0 }, lodDistanceScaling = 0.65 },		-- Medium
						{ viewNearFar = { 4.0, 7500.0 }, fogStartEndFarPerc = { 0.25, 1.0 }, lodDistanceScaling = 1.0 },		-- High
						{ viewNearFar = { 4.0, 15000.0 }, fogStartEndFarPerc = { 0.125, 1.0 }, lodDistanceScaling = 10 },	-- Camera tool
						-- { viewNearFar = { 0.5, 5000.0 }, fogStartEndFarPerc = { 1.0, 1.0 }, lodDistanceScaling = 1.0 },		-- Cockpit view original
						{ viewNearFar = { 0.5, 500.0 }, fogStartEndFarPerc = { 0.6, 1.0 }, lodDistanceScaling = 0.125 },		-- Cockpit view
					}
				end
			end

			local spdrp = modSettings.getModParamFromRunFn('simPersonDestinationRecomputationProbability')
			if spdrp == 0 then
				game.config.simPersonDestinationRecomputationProbability = 0.1
			elseif spdrp == 1 then
				game.config.simPersonDestinationRecomputationProbability = 0.5
			elseif spdrp == 3 then
				game.config.simPersonDestinationRecomputationProbability = 1.5
			elseif spdrp == 4 then
				game.config.simPersonDestinationRecomputationProbability = 2.0
			-- else
			-- 	game.config.simPersonDestinationRecomputationProbability = 1.0
			end

			logger.print('runFn leaving, game.config = ') logger.debugPrint(game.config)
		end,
	}
end
