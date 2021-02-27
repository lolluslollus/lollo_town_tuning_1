-- LOLLO BODGE we need this to exchange data between updateFn(CONSTRUCTION) and the game script.
-- at the moment, we have no way of reading up-to-date game script data from updateFn.
-- Whenever a game loads or the user changes some data, the temp file is updated.
-- Whenever construction.TOWN_BUILDING.updateFn fires, it will read their latest version of it.

-- local arrayUtils = require('lollo_town_tuning.arrayUtils')
local fileUtils = require('lollo_town_tuning.fileUtils')
local logger = require('lollo_town_tuning.logger')

local _currentDir = fileUtils.getParentDirFromPath(fileUtils.getCurrentPath())
-- print('current dir =', _currentDir)
local _fileName = _currentDir .. '/commonDataTemp.lua'
-- print('file name =', _fileName)

-- local _helperBuffer = nil -- LOLLO NOTE it would be nice to have these, but it won't work across threads, see comments below.
local helper = {
    defaultCapacityFactor = 1.0,
    defaultConsumptionFactor = 1.2,
    defaultPersonCapacityFactor = 1.0,
}
helper.get = function()
    -- if _helperBuffer ~= nil then -- always nil coz set in a different state (thread)
    --     logger.print('buffer in action')
    --     return _helperBuffer
    -- end

    local result = fileUtils.loadTable(_fileName)
    if type(result) ~= 'table' then
        result = {
            capacityFactor = helper.defaultCapacityFactor,
            consumptionFactor = helper.defaultConsumptionFactor,
            personCapacityFactor = helper.defaultPersonCapacityFactor
        }
        -- print('no table found, returning defaults')
    end
    -- _helperBuffer = arrayUtils.cloneDeepOmittingFields(result) -- NO!
    -- logger.print('returning data =') logger.debugPrint(result)
    return result
end
helper.set = function(newData)
    if type(newData) ~= 'table' then return end

    local savedData = fileUtils.loadTable(_fileName)
    if not(savedData)
    or savedData.capacityFactor ~= newData.capacityFactor
    or savedData.consumptionFactor ~= newData.consumptionFactor
    or savedData.personCapacityFactor ~= newData.personCapacityFactor then
        -- _helperBuffer = arrayUtils.cloneDeepOmittingFields(newData)
        logger.print('saving table, data =') -- logger.debugPrint(newData)
        fileUtils.saveTable(newData, _fileName)
    end
end

return helper
