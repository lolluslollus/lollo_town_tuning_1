local arrayUtils = require('lollo_building_tuning.arrayUtils')
local fileUtils = require('lollo_building_tuning.fileUtils')
local _currentDir = fileUtils.getParentDirFromPath(fileUtils.getCurrentPath())
print('current dir =', _currentDir)
local _fileName = _currentDir .. '/commonDataTemp.lua'
print('file name =', _fileName)

local _defaultCapacityFactorDelta = 0.48
local _defaultCapacityFactor = 1.0
local _defaultConsumptionFactorDelta = 0.58
local _defaultConsumptionFactor = 1.2
local _towns = {}

local helper = {
    common = {
        get = function()
            local result = fileUtils.loadTable(_fileName)
            if type(result) ~= 'table' then
                print('initialising the common data file')
                result = {
                    capacityFactor = _defaultCapacityFactor,
                    consumptionFactor = _defaultConsumptionFactor
                }
                fileUtils.saveTable(result, _fileName)
            end
            return result
            -- return arrayUtils.cloneDeepOmittingFields(_common)
        end,
        setCapacityFactor = function(isUp)
            local newCommon = fileUtils.loadTable(_fileName)
            if type(newCommon.capacityFactor) ~= 'number' then return end
            if not(isUp) and newCommon.capacityFactor - _defaultCapacityFactorDelta < 0 then return end

            if isUp then newCommon.capacityFactor = newCommon.capacityFactor + _defaultCapacityFactorDelta
            else newCommon.capacityFactor = newCommon.capacityFactor - _defaultCapacityFactorDelta
            end

            fileUtils.saveTable(
                newCommon,
                _fileName
            )
        end,
        setConsumptionFactor = function(isUp)
            local newCommon = fileUtils.loadTable(_fileName)
            if type(newCommon.consumptionFactor) ~= 'number' then return end
            if not(isUp) and newCommon.consumptionFactor - _defaultConsumptionFactorDelta < 0 then return end

            if isUp then newCommon.consumptionFactor = newCommon.consumptionFactor + _defaultConsumptionFactorDelta
            else newCommon.consumptionFactor = newCommon.consumptionFactor - _defaultConsumptionFactorDelta
            end

            fileUtils.saveTable(
                newCommon,
                _fileName
            )
        end
    },
    towns = {
        get = function()
            return arrayUtils.cloneDeepOmittingFields(_towns)
        end,
        set = function(newTowns)
            if type(newTowns) ~= 'table' then return end

            _towns = newTowns
        end
    }
}

return helper