-- LOLLO BODGE we need this to exchange data between construction.TOWN_BUILDING.updateFn() and the game script.
-- at the moment, we have no way of reading up-to-date game script data from updateFn.
-- Whenever a game loads or the user changes some data, the temp file is updated.
-- Whenever construction.TOWN_BUILDING.updateFn() fires, it will read their latest version of it.

-- local arrayUtils = require('lollo_town_tuning.arrayUtils')
local fileUtils = require('lollo_town_tuning.fileUtils')
local logger = require('lollo_town_tuning.logger')

local _currentDir = fileUtils.getParentDirFromPath(fileUtils.getCurrentPath())
-- logger.print('current dir =', _currentDir)
local _fileName = _currentDir .. '/commonDataTemp.lua'
-- logger.print('file name =', _fileName)

-- local _helperBuffer = nil -- LOLLO NOTE it would be nice to have this, but it won't work across states, see comments below.
local me = {
    defaultCapacityFactor = 1.0,
    defaultConsumptionFactor = 1.2,
    defaultPersonCapacityFactor = 1.0,
}
me.get = function()
    -- if _helperBuffer ~= nil then -- always nil coz set in a different state (thread)
    --     logger.print('buffer in action')
    --     return _helperBuffer
    -- end

    local result = fileUtils.loadTable(_fileName)
    if type(result) ~= 'table' then
        result = {
            capacityFactor = me.defaultCapacityFactor,
            consumptionFactor = me.defaultConsumptionFactor,
            personCapacityFactor = me.defaultPersonCapacityFactor
        }
        -- logger.print('no table found, returning defaults')
    end

    -- _helperBuffer = arrayUtils.cloneDeepOmittingFields(result) -- NO!
    -- logger.print('returning data =') logger.debugPrint(result)
    return result
end
me.set = function(newData)
    if type(newData) ~= 'table' then return end

    local savedData = fileUtils.loadTable(_fileName)
    if not(savedData)
    or savedData.capacityFactor ~= newData.capacityFactor
    or savedData.consumptionFactor ~= newData.consumptionFactor
    or savedData.personCapacityFactor ~= newData.personCapacityFactor
    then
        -- _helperBuffer = arrayUtils.cloneDeepOmittingFields(newData)
        logger.print('saving table, data =') -- logger.debugPrint(newData)
        -- _G.lollo_town_tuning = { commonData = newData } -- NO!
        fileUtils.saveTable(newData, _fileName)
    end
end

return me
