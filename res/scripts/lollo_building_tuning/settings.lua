local results = {}

local _values = {
	townDevelopInterval = 20.0, -- default is 60.0
	townMajorStreetAngleRange = 10.0, -- default is 0.0
}

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

results.getParam = function(fieldName)
    local modSettings = _getModSettings1() or _getModSettings2()
    if not(modSettings) then
        print('LOLLO town tuning cannot read modSettings')
        return nil
    end

    return modSettings[fieldName]
end

results.getValue = function(fieldName)
    return _values[fieldName]
end

results.setModParamsFromRunFn = function(thisModParams)
    -- LOLLO NOTE if default values are set, modParams in runFn will be an empty table,
    -- so thisModParams here will be nil
    if type(game) ~= 'table' or type(game.config) ~= 'table' then return end

    if type(game.config._lolloTownTuning) ~= 'table' then
        game.config._lolloTownTuning = {}
    end

    if type(thisModParams) == 'table' and thisModParams.noSkyscrapers == 0 then
        game.config._lolloTownTuning.noSkyscrapers = 0
    else
        game.config._lolloTownTuning.noSkyscrapers = 1
    end

	if type(thisModParams) == 'table' and thisModParams.noSquareCrossings == 0 then
        game.config._lolloTownTuning.noSquareCrossings = 0
    else
        game.config._lolloTownTuning.noSquareCrossings = 1
    end

	if type(thisModParams) == 'table' and thisModParams.fasterLowGeometry == 0 then
        game.config._lolloTownTuning.fasterLowGeometry = 0
    else
        game.config._lolloTownTuning.fasterLowGeometry = 1
    end

	if type(thisModParams) == 'table' and thisModParams.fasterTownDevelopInterval == 0 then
        game.config._lolloTownTuning.fasterTownDevelopInterval = 0
    else
        game.config._lolloTownTuning.fasterTownDevelopInterval = 1
    end
end

return results