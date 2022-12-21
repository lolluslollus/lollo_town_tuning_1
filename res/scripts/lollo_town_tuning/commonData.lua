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
-- returns something in any case, ignoring errors,
-- then an error string if there was trouble loading
me.get = function()
    -- if _helperBuffer ~= nil then -- always nil coz set in a different state (thread)
    --     logger.print('buffer in action')
    --     return _helperBuffer
    -- end

    -- print('getting game.LOLLO_TOWN_TUNING =') debugPrint(game.LOLLO_TOWN_TUNING) -- not shared across states
    -- print('getting game.config.LOLLO_TOWN_TUNING =') debugPrint(game.config.LOLLO_TOWN_TUNING) -- not shared across states
    -- print('getting _G.LOLLO_TOWN_TUNING =') debugPrint(_G.LOLLO_TOWN_TUNING) -- not shared across states
    local savedData, err = fileUtils.loadTable(_fileName)
    -- logger.print('savedData =') logger.debugPrint(savedData)
    if type(savedData) ~= 'table' then
        savedData = {
            capacityFactor = me.defaultCapacityFactor,
            consumptionFactor = me.defaultConsumptionFactor,
            personCapacityFactor = me.defaultPersonCapacityFactor
        }
        -- logger.print('no table found, returning defaults')
    end

    -- _helperBuffer = arrayUtils.cloneDeepOmittingFields(savedData) -- NO!
    -- logger.print('returning data =') logger.debugPrint(savedData)
    return savedData, err
end
-- returns false if nothing was saved, or true if something was saved,
-- then an error string if there was trouble loading,
-- then an error string if there was trouble saving.
me.set = function(newData)
    if type(newData) ~= 'table' then return false, 'newData is empty' end

    local savedData, errLoading = fileUtils.loadTable(_fileName)
    -- logger.print('savedData =') logger.debugPrint(savedData)

    local errSaving, isSaved = nil, false
    if type(savedData) ~= 'table'
    or savedData.capacityFactor ~= newData.capacityFactor
    or savedData.consumptionFactor ~= newData.consumptionFactor
    or savedData.personCapacityFactor ~= newData.personCapacityFactor
    then
        -- game.LOLLO_TOWN_TUNING = newData -- not shared across states
        -- game.config.LOLLO_TOWN_TUNING = newData -- not shared across states
        -- _G.LOLLO_TOWN_TUNING.capacityFactor = newData.capacityFactor -- not shared across states
        -- _G.LOLLO_TOWN_TUNING.consumptionFactor = newData.consumptionFactor
        -- _G.LOLLO_TOWN_TUNING.personCapacityFactor = newData.personCapacityFactor
        -- _helperBuffer = arrayUtils.cloneDeepOmittingFields(newData)
        -- logger.print('saving table, data =') -- logger.debugPrint(newData)
        errSaving = fileUtils.saveTable(newData, _fileName)
        isSaved = not(errSaving)
    end

    return isSaved, errLoading, errSaving
end

return me
