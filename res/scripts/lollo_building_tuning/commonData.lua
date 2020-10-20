local fileUtils = require('lollo_building_tuning.fileUtils')
local _currentDir = fileUtils.getParentDirFromPath(fileUtils.getCurrentPath())
-- print('current dir =', _currentDir)
local _fileName = _currentDir .. '/commonDataTemp.lua'
-- print('file name =', _fileName)

local _defaultCapacityFactor = 1.0
local _defaultConsumptionFactor = 1.2
local _defaultPersonCapacityFactor = 1.0

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
        getCapacityFactorIndex = function(factor)
            if type(factor) ~= 'number' then factor = _defaultCapacityFactor end

            local result = 3
            if factor <= 0.1 then
                result = 1
            elseif factor == 0.5 then
                result = 2
            elseif factor == 1.5 then
                result = 4
            elseif factor >= 2 then
                result = 5
            end

            return result
        end,
        setCapacityFactor = function(index)
            if type(index) ~= 'number' then return end

            local newCommon = fileUtils.loadTable(_fileName)
            if type(newCommon.capacityFactor) ~= 'number' then newCommon.capacityFactor = _defaultCapacityFactor end

            local newFactor = _defaultCapacityFactor
            if index <= 1 then
                newFactor = 0.1
            elseif index == 2 then
                newFactor = 0.5
            elseif index == 4 then
                newFactor = 1.5
            elseif index >= 5 then
                newFactor = 2.0
            end

            if newFactor == newCommon.capacityFactor then return end

            newCommon.capacityFactor = newFactor
            fileUtils.saveTable(newCommon, _fileName)
        end,
        getConsumptionFactorIndex = function(factor)
            if type(factor) ~= 'number' then factor = _defaultConsumptionFactor end

            local result = 3
            if factor <= 0.1 then
                result = 1
            elseif factor == 0.6 then
                result = 2
            elseif factor == 1.8 then
                result = 4
            elseif factor >= 2.4 then
                result = 5
            end

            return result
        end,
        setConsumptionFactor = function(index)
            if type(index) ~= 'number' then return end

            local newCommon = fileUtils.loadTable(_fileName)
            if type(newCommon.consumptionFactor) ~= 'number' then newCommon.consumptionFactor = _defaultConsumptionFactor end

            local newFactor = _defaultConsumptionFactor
            if index <= 1 then
                newFactor = 0.1
            elseif index == 2 then
                newFactor = 0.6
            elseif index == 4 then
                newFactor = 1.8
            elseif index >= 5 then
                newFactor = 2.4
            end

            if newFactor == newCommon.consumptionFactor then return end

            newCommon.consumptionFactor = newFactor
            fileUtils.saveTable(newCommon, _fileName)
        end,
        getPersonCapacityFactorIndex = function(factor)
            if type(factor) ~= 'number' then factor = _defaultPersonCapacityFactor end

            local result = 3
            if factor <= 0.1 then
                result = 1
            elseif factor == 0.5 then
                result = 2
            elseif factor == 1.5 then
                result = 4
            elseif factor >= 2.0 then
                result = 5
            end

            return result
        end,
        setPersonCapacityFactor = function(index)
            if type(index) ~= 'number' then return end

            local newCommon = fileUtils.loadTable(_fileName)
            if type(newCommon.personCapacityFactor) ~= 'number' then newCommon.personCapacityFactor = _defaultPersonCapacityFactor end

            local newFactor = _defaultPersonCapacityFactor
            if index <= 1 then
                newFactor = 0.1
            elseif index == 2 then
                newFactor = 0.5
            elseif index == 4 then
                newFactor = 1.5
            elseif index >= 5 then
                newFactor = 2.0
            end

            if newFactor == newCommon.personCapacityFactor then return end

            newCommon.personCapacityFactor = newFactor
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