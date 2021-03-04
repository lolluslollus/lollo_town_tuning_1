local logger = require('lollo_town_tuning.logger')
local results = {}

local function _getModSettings1()
    if type(game) ~= 'table' or type(game.config) ~= 'table' then return nil end
    return game.config._lolloTownTuning
end

local function _getModSettings2()
    if type(api) ~= 'table' or type(api.res) ~= 'table' or type(api.res.getBaseConfig) ~= 'table' then return end

    local baseConfig = api.res.getBaseConfig()
    if not(baseConfig) then return end

    return baseConfig._lolloTownTuning
end

results.defaultParams = {
    fasterLowGeometry = 1,
    fasterTownDevelopInterval = 1,
    noSkyscrapers = 1,
    noSquareCrossings = 1,
    simPersonDestinationRecomputationProbability = 2,
}

results.getParam = function(fieldName)
    local modSettings = _getModSettings1() or _getModSettings2()
    if not(modSettings) then
        print('WARNING: lollo town tuning cannot read modSettings')
        return nil
    end

    return modSettings[fieldName]
end

results.setModParamsFromRunFn = function(modParams)
    -- LOLLO NOTE if all default values are set, modParams in runFn will be an empty table,
    -- so thisModParams here will be nil
    -- In this case, we assign the default values.
    if type(game) ~= 'table' or type(game.config) ~= 'table' or modParams == nil then return end
    local thisModParams = modParams[getCurrentModId()]

    if type(game.config._lolloTownTuning) ~= 'table' then
        game.config._lolloTownTuning = {}
    end

	if type(thisModParams) == 'table' and thisModParams.fasterLowGeometry == 0 then
        game.config._lolloTownTuning.fasterLowGeometry = 0
    else
        game.config._lolloTownTuning.fasterLowGeometry = results.defaultParams.fasterLowGeometry
    end

	if type(thisModParams) == 'table' and thisModParams.fasterTownDevelopInterval == 0 then
        game.config._lolloTownTuning.fasterTownDevelopInterval = 0
    else
        game.config._lolloTownTuning.fasterTownDevelopInterval = results.defaultParams.fasterTownDevelopInterval
    end

    if type(thisModParams) == 'table' and thisModParams.noSkyscrapers == 0 then
        game.config._lolloTownTuning.noSkyscrapers = 0
    else
        game.config._lolloTownTuning.noSkyscrapers = results.defaultParams.noSkyscrapers
    end

	if type(thisModParams) == 'table' and thisModParams.noSquareCrossings == 0 then
        game.config._lolloTownTuning.noSquareCrossings = 0
    else
        game.config._lolloTownTuning.noSquareCrossings = results.defaultParams.noSquareCrossings
    end

    if type(thisModParams) == 'table'
    and type(thisModParams.simPersonDestinationRecomputationProbability) == 'number'
    and thisModParams.simPersonDestinationRecomputationProbability >= 0
    and thisModParams.simPersonDestinationRecomputationProbability <= 4
    then
        game.config._lolloTownTuning.simPersonDestinationRecomputationProbability = thisModParams.simPersonDestinationRecomputationProbability
    else
        game.config._lolloTownTuning.simPersonDestinationRecomputationProbability = results.defaultParams.simPersonDestinationRecomputationProbability
    end

    logger.print('modParams =') logger.debugPrint(modParams)
    logger.print('thisModParams =') logger.debugPrint(thisModParams)
    logger.print('game.config._lolloTownTuning =') logger.debugPrint(game.config._lolloTownTuning)
end

return results