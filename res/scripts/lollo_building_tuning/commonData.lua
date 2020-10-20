local fileUtils = require('lollo_building_tuning.fileUtils')
local _currentDir = fileUtils.getParentDirFromPath(fileUtils.getCurrentPath())
-- print('current dir =', _currentDir)
local _fileName = _currentDir .. '/commonDataTemp.lua'
-- print('file name =', _fileName)

local _defaultCapacityFactorDelta = 0.49
local _defaultCapacityFactor = 1.0
local _defaultConsumptionFactorDelta = 0.59
local _defaultConsumptionFactor = 1.2
local _defaultPersonCapacityFactorDelta = 0.49
local _defaultPersonCapacityFactor = 1.0
local _maxCapacityFactor = 2.0
local _maxConsumptionFactor = 2.4
local _maxPersonCapacityFactor = 2.0

local helper = {
    cargoTypes = {
        getAll = function()
            local cargoNames = api.res.cargoTypeRep.getAll()
            if not(cargoNames) then return {} end

            local results = {}
            for k, v in pairs(cargoNames) do
                if v ~= 'PASSENGERS' then -- note that passengers has id = 0
                    results[k] = api.res.cargoTypeRep.get(k)
                end
            end

            return results
        end,
    },
    shared = {
        get = function()
            local result = fileUtils.loadTable(_fileName)
            if type(result) ~= 'table' then
                -- print('initialising the common data file')
                result = {
                    capacityFactor = _defaultCapacityFactor,
                    consumptionFactor = _defaultConsumptionFactor,
                    personCapacityFactor = _defaultPersonCapacityFactor
                }
                fileUtils.saveTable(result, _fileName)
            end
            return result
        end,
        setCapacityFactor = function(isUp)
            local newCommon = fileUtils.loadTable(_fileName)
            if type(newCommon.capacityFactor) ~= 'number' then return end
            if isUp and newCommon.capacityFactor + _defaultCapacityFactorDelta > _maxCapacityFactor then return end
            if not(isUp) and newCommon.capacityFactor - _defaultCapacityFactorDelta < 0 then return end

            if isUp then newCommon.capacityFactor = newCommon.capacityFactor + _defaultCapacityFactorDelta
            else newCommon.capacityFactor = newCommon.capacityFactor - _defaultCapacityFactorDelta
            end

            fileUtils.saveTable(newCommon, _fileName)
        end,
        setConsumptionFactor = function(isUp)
            local newCommon = fileUtils.loadTable(_fileName)
            if type(newCommon.consumptionFactor) ~= 'number' then return end
            if isUp and newCommon.consumptionFactor + _defaultConsumptionFactorDelta > _maxConsumptionFactor then return end
            if not(isUp) and newCommon.consumptionFactor - _defaultConsumptionFactorDelta < 0 then return end

            if isUp then newCommon.consumptionFactor = newCommon.consumptionFactor + _defaultConsumptionFactorDelta
            else newCommon.consumptionFactor = newCommon.consumptionFactor - _defaultConsumptionFactorDelta
            end

            fileUtils.saveTable(newCommon, _fileName)
        end,
        setPersonCapacityFactor = function(isUp)
            local newCommon = fileUtils.loadTable(_fileName)
            if type(newCommon.personCapacityFactor) ~= 'number' then return end
            if isUp and newCommon.personCapacityFactor + _defaultPersonCapacityFactorDelta > _maxPersonCapacityFactor then return end
            if not(isUp) and newCommon.personCapacityFactor - _defaultPersonCapacityFactorDelta < 0 then return end

            if isUp then newCommon.personCapacityFactor = newCommon.personCapacityFactor + _defaultPersonCapacityFactorDelta
            else newCommon.personCapacityFactor = newCommon.personCapacityFactor - _defaultPersonCapacityFactorDelta
            end

            fileUtils.saveTable(newCommon, _fileName)
        end,
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