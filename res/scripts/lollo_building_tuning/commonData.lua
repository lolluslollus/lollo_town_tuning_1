local fileUtils = require('lollo_building_tuning.fileUtils')
local _currentDir = fileUtils.getParentDirFromPath(fileUtils.getCurrentPath())
-- print('current dir =', _currentDir)
local _fileName = _currentDir .. '/commonDataTemp.lua'
-- print('file name =', _fileName)

local _defaultCapacityFactorDelta = 0.48
local _defaultCapacityFactor = 1.0
local _defaultConsumptionFactorDelta = 0.58
local _defaultConsumptionFactor = 1.2

local helper = {
    common = {
        get = function()
            local result = fileUtils.loadTable(_fileName)
            if type(result) ~= 'table' then
                -- print('initialising the common data file')
                result = {
                    capacityFactor = _defaultCapacityFactor,
                    consumptionFactor = _defaultConsumptionFactor
                }
                fileUtils.saveTable(result, _fileName)
            end
            return result
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
            local townCapacities = api.engine.system.townBuildingSystem.getTown2personCapacitiesMap()
            if not(townCapacities) then return {} end

            local results = {}
            for id, personCapacities in pairs(townCapacities) do
                results[id] = {
                    personCapacities = personCapacities,
                    townStatWindowId = 'temp.view.entity_' .. tostring(id)
                }
            end
            return results
        end,
        -- set = function(newTowns)
        --     if type(newTowns) ~= 'table' then return end

        --     _towns = newTowns
        -- end
    }
}

return helper