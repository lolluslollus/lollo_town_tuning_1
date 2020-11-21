-- LOLLO BODGE we need this to exchange data between runFn(CONSTRUCTION) and the game script.
-- at the moment, we have no way of reading up-to-date game script data from a runFn.
-- Whenever a game loads or the user changes some data, the temp file is updated.
-- Whenever construction.TOWN_BUILDING.updateFn fires, it will read their latest version of it.

local fileUtils = require('lollo_town_tuning.fileUtils')
local _currentDir = fileUtils.getParentDirFromPath(fileUtils.getCurrentPath())
-- print('current dir =', _currentDir)
local _fileName = _currentDir .. '/commonDataTemp.lua'
-- print('file name =', _fileName)

local helper = {
    defaultCapacityFactor = 1.0,
    defaultConsumptionFactor = 1.2,
    defaultPersonCapacityFactor = 1.0,
}
helper.get = function()
    local result = fileUtils.loadTable(_fileName)
    if type(result) ~= 'table' then
        result = {
            capacityFactor = helper.defaultCapacityFactor,
            consumptionFactor = helper.defaultConsumptionFactor,
            personCapacityFactor = helper.defaultPersonCapacityFactor
        }
        -- print('no table found, returning defaults')
        -- fileUtils.saveTable(result, _fileName)
    end
    -- print('returning data =')
    -- debugPrint(result)
    return result
end
helper.set = function(data)
    if type(data) ~= 'table' then return end

    local savedData = fileUtils.loadTable(_fileName)
    if not(savedData)
    or savedData.capacityFactor ~= data.capacityFactor
    or savedData.consumptionFactor ~= data.consumptionFactor
    or savedData.personCapacityFactor ~= data.personCapacityFactor then
        -- print('saving table, data =')
        -- debugPrint(data)
        fileUtils.saveTable(data, _fileName)
    end
end

return helper
