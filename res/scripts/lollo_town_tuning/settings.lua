local logger = require('lollo_town_tuning.logger')


local _utils = {
    getModSettingsFromGameConfig = function()
        if type(game) ~= 'table' or type(game.config) ~= 'table' then return nil end
        return game.config._lolloTownTuning
    end,
    getModSettingsFromApi = function()
        if type(api) ~= 'table' or type(api.res) ~= 'table' or type(api.res.getBaseConfig) ~= 'table' then return end

        local baseConfig = api.res.getBaseConfig()
        if not(baseConfig) then return end

        return baseConfig._lolloTownTuning
    end,
}

local results = {
    defaultParams = {
        eraBStartYear = 0,
        eraCStartYear = 0,
        fasterLowGeometry = 1,
        fasterTownDevelopInterval = 1,
        noSkyscrapers = 1,
        noSquareCrossings = 1,
        oldBuildingsInNewEras = 0,
        simPersonDestinationRecomputationProbability = 2,
    },
    paramValueNumbers = {
        eraBStartYear = { 1920, 1850, 1900, 1950, 1980, -1 },
        eraCStartYear = { 1980, 1850, 1900, 1920, 1950, -1 },
    },
}

results.getModParamFromRunFn = function(fieldName)
    local modSettings = _utils.getModSettingsFromGameConfig()
    if not(modSettings) then
        logger.warn('cannot read modSettings, falling back to default')
        return results.defaultParams[fieldName]
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

	if type(thisModParams) == 'table' and type(thisModParams.fasterLowGeometry) == 'number' then
        game.config._lolloTownTuning.fasterLowGeometry = thisModParams.fasterLowGeometry
    else
        game.config._lolloTownTuning.fasterLowGeometry = results.defaultParams.fasterLowGeometry
    end

	if type(thisModParams) == 'table' and type(thisModParams.fasterTownDevelopInterval) == 'number' then
        game.config._lolloTownTuning.fasterTownDevelopInterval = thisModParams.fasterTownDevelopInterval
    else
        game.config._lolloTownTuning.fasterTownDevelopInterval = results.defaultParams.fasterTownDevelopInterval
    end

    if type(thisModParams) == 'table' and type(thisModParams.noSkyscrapers) == 'number' then
        game.config._lolloTownTuning.noSkyscrapers = thisModParams.noSkyscrapers
    else
        game.config._lolloTownTuning.noSkyscrapers = results.defaultParams.noSkyscrapers
    end

    if type(thisModParams) == 'table' and type(thisModParams.oldBuildingsInNewEras) == 'number' then
        game.config._lolloTownTuning.oldBuildingsInNewEras = thisModParams.oldBuildingsInNewEras
    else
        game.config._lolloTownTuning.oldBuildingsInNewEras = results.defaultParams.oldBuildingsInNewEras
    end

    if type(thisModParams) == 'table' and type(thisModParams.eraBStartYear) == 'number' then
        game.config._lolloTownTuning.eraBStartYear = thisModParams.eraBStartYear
    else
        game.config._lolloTownTuning.eraBStartYear = results.defaultParams.eraBStartYear
    end

    if type(thisModParams) == 'table' and type(thisModParams.eraCStartYear) == 'number' then
        game.config._lolloTownTuning.eraCStartYear = thisModParams.eraCStartYear
    else
        game.config._lolloTownTuning.eraCStartYear = results.defaultParams.eraCStartYear
    end

	if type(thisModParams) == 'table' and type(thisModParams.noSquareCrossings) == 'number' then
        game.config._lolloTownTuning.noSquareCrossings = thisModParams.noSquareCrossings
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
