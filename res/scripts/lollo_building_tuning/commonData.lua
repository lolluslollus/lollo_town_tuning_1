local arrayUtils = require('lollo_building_tuning.arrayUtils')
local fileUtils = require('lollo_building_tuning.fileUtils')
fileUtils.saveTable(
    {
        consumptionFactor = 1.2
    },
    'lollo_building_tuning.commonDataTemp.lua'
)
local _defaultConsumptionFactorDelta = 0.5
local _towns = {}

local helper = {
    common = {},
    towns = {}
}
helper.common.get = function()
    local result = fileUtils.loadTable('lollo_building_tuning.commonDataTemp.lua')
    print('commonDataTemp = ')
    debugPrint(result)
    return result
    -- return arrayUtils.cloneDeepOmittingFields(_common)
end

helper.common.setConsumptionFactor = function(isUp)
    local newCommon = fileUtils.loadTable('lollo_building_tuning.commonDataTemp.lua')
    if type(newCommon.consumptionFactor) ~= 'number' then return end
    if not(isUp) and newCommon.consumptionFactor - _defaultConsumptionFactorDelta < 0 then return end

    if(isUp) then newCommon.consumptionFactor = newCommon.consumptionFactor + _defaultConsumptionFactorDelta
    else newCommon.consumptionFactor = newCommon.consumptionFactor - _defaultConsumptionFactorDelta
    end

    fileUtils.saveTable(
        newCommon,
        'lollo_building_tuning.commonDataTemp.lua'
    )
end

helper.towns.get = function()
    return arrayUtils.cloneDeepOmittingFields(_towns)
end

helper.towns.set = function(newTowns)
    if type(newTowns) ~= 'table' then return end

    _towns = newTowns
end

return helper