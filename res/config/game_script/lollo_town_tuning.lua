local arrayUtils = require('lollo_building_tuning.arrayUtils')
local commonData = require('lollo_building_tuning.commonData')
local function _myErrorHandler(err)
    print('lollo town tuning caught error: ', err)
end

local _eventId = '__lolloTownTuningEvent__'
local _state = {
    townId4CapacityFactorNeedingUpdate = false,
    townId4ConsumptionFactorNeedingUpdate = false,
    townId4PersonCapacityFactorNeedingUpdate = false,
}
local _utils = {
    guiAddTownStatButtons = function(windowId, townId, common)
        -- LOLLO TODO put this in a UI that is common to all towns
        print('town stats window opened, id, name, param, api.gui.util.getById ==')
        -- debugPrint(windowId)
        -- debugPrint(name)
        -- debugPrint(param)
        -- debugPrint(api.gui.util.getById(windowId))

        local windowContent = api.gui.util.getById(windowId):getContent()
        local editorTab = windowContent:getTab(3)
        local editorTabLayout = editorTab:getLayout()


        local capacityFactorTextViewTitle = api.gui.comp.TextView.new('Capacity Factor')
        local capacityFactorTextViewDown = api.gui.comp.TextView.new("-")
        local capacityFactorButtonDown = api.gui.comp.Button.new(capacityFactorTextViewDown, true)
        capacityFactorButtonDown:setId('lolloTownTuning_CapacityFactorButtonDown_' .. tostring(townId))
        -- buttonDown:setStyleClassList({ "negative" })
        local capacityFactorTextViewValue = api.gui.comp.TextView.new(tostring(common.capacityFactor))
        capacityFactorTextViewValue:setId('lolloTownTuning_CapacityFactorValue_' .. tostring(townId))
        local capacityFactorTextViewUp = api.gui.comp.TextView.new("+")
        local capacityFactorButtonUp = api.gui.comp.Button.new(capacityFactorTextViewUp, true)
        capacityFactorButtonUp:setId('lolloTownTuning_CapacityFactorButtonUp_' .. tostring(townId))
        -- buttonUp:setStyleClassList({ "positive" })

        local consumptionFactorTextViewTitle = api.gui.comp.TextView.new('Consumption Factor')
        local consumptionFactorTextViewDown = api.gui.comp.TextView.new("-")
        local consumptionFactorButtonDown = api.gui.comp.Button.new(consumptionFactorTextViewDown, true)
        consumptionFactorButtonDown:setId('lolloTownTuning_ConsumptionFactorButtonDown_' .. tostring(townId))
        -- buttonDown:setStyleClassList({ "negative" })
        local consumptionFactorTextViewValue = api.gui.comp.TextView.new(tostring(common.consumptionFactor))
        consumptionFactorTextViewValue:setId('lolloTownTuning_ConsumptionFactorValue_' .. tostring(townId))
        local consumptionFactorTextViewUp = api.gui.comp.TextView.new("+")
        local consumptionFactorButtonUp = api.gui.comp.Button.new(consumptionFactorTextViewUp, true)
        consumptionFactorButtonUp:setId('lolloTownTuning_ConsumptionFactorButtonUp_' .. tostring(townId))
        -- buttonUp:setStyleClassList({ "positive" })

        local personCapacityFactorTextViewTitle = api.gui.comp.TextView.new('Person Capacity Factor')
        local personCapacityFactorTextViewDown = api.gui.comp.TextView.new("-")
        local personCapacityFactorButtonDown = api.gui.comp.Button.new(personCapacityFactorTextViewDown, true)
        personCapacityFactorButtonDown:setId('lolloTownTuning_PersonCapacityFactorButtonDown_' .. tostring(townId))
        -- buttonDown:setStyleClassList({ "negative" })
        local personCapacityFactorTextViewValue = api.gui.comp.TextView.new(tostring(common.personCapacityFactor))
        personCapacityFactorTextViewValue:setId('lolloTownTuning_PersonCapacityFactorValue_' .. tostring(townId))
        local personCapacityFactorTextViewUp = api.gui.comp.TextView.new("+")
        local personCapacityFactorButtonUp = api.gui.comp.Button.new(personCapacityFactorTextViewUp, true)
        personCapacityFactorButtonUp:setId('lolloTownTuning_PersonCapacityFactorButtonUp_' .. tostring(townId))
        -- buttonUp:setStyleClassList({ "positive" })

        editorTabLayout:addItem(capacityFactorTextViewTitle)
        local capacityTable = api.gui.comp.Table.new(1, 'NONE')
        capacityTable:setNumCols(3)
        capacityTable:addRow({capacityFactorButtonDown, capacityFactorTextViewValue, capacityFactorButtonUp})
        editorTabLayout:addItem(capacityTable)

        editorTabLayout:addItem(consumptionFactorTextViewTitle)
        local consumptionTable = api.gui.comp.Table.new(1, 'NONE')
        consumptionTable:setNumCols(3)
        consumptionTable:addRow({consumptionFactorButtonDown, consumptionFactorTextViewValue, consumptionFactorButtonUp})
        editorTabLayout:addItem(consumptionTable)

        editorTabLayout:addItem(personCapacityFactorTextViewTitle)
        local personCapacityTable = api.gui.comp.Table.new(1, 'NONE')
        personCapacityTable:setNumCols(3)
        personCapacityTable:addRow({personCapacityFactorButtonDown, personCapacityFactorTextViewValue, personCapacityFactorButtonUp})
        editorTabLayout:addItem(personCapacityTable)
    end,
    guiUpdateCapacityFactorValue = function()
        if type(_state.townId4CapacityFactorNeedingUpdate) ~= 'number' then return end

        local textBox = api.gui.util.getById('lolloTownTuning_CapacityFactorValue_' .. tostring(_state.townId4CapacityFactorNeedingUpdate))
        if textBox then
            textBox:setText(tostring(commonData.common.get().capacityFactor or 'NIL'))
        end
        _state.townId4CapacityFactorNeedingUpdate = false
    end,
    guiUpdateConsumptionFactorValue = function()
        if type(_state.townId4ConsumptionFactorNeedingUpdate) ~= 'number' then return end

        local textBox = api.gui.util.getById('lolloTownTuning_ConsumptionFactorValue_' .. tostring(_state.townId4ConsumptionFactorNeedingUpdate))
        if textBox then
            textBox:setText(tostring(commonData.common.get().consumptionFactor or 'NIL'))
        end
        _state.townId4ConsumptionFactorNeedingUpdate = false
    end,
    guiUpdatePersonCapacityFactorValue = function()
        if type(_state.townId4PersonCapacityFactorNeedingUpdate) ~= 'number' then return end

        local textBox = api.gui.util.getById('lolloTownTuning_PersonCapacityFactorValue_' .. tostring(_state.townId4PersonCapacityFactorNeedingUpdate))
        if textBox then
            textBox:setText(tostring(commonData.common.get().personCapacityFactor or 'NIL'))
        end
        _state.townId4PersonCapacityFactorNeedingUpdate = false
    end,
    replaceBuildingWithSelf = function(oldBuildingId)
        -- no good, leads to multithreading nightmare
        print('oldBuildingId =', oldBuildingId or 'NIL')
        if type(oldBuildingId) ~= 'number' or oldBuildingId < 0 then return end

        local oldBuilding = api.engine.getComponent(oldBuildingId, api.type.ComponentType.TOWN_BUILDING)
        print('oldBuilding =')
        debugPrint(oldBuilding)
        if not(oldBuilding) then return end
        -- skip buildings that do not accept freight
        if not(oldBuilding.personCapacity) then return end
        if type(oldBuilding.stockList) ~= 'number' then return end
        if oldBuilding.stockList < 0 then return end
        local oldConstructionId = oldBuilding.personCapacity -- whatever they were thinking
        print('oldConstructionId =')
        debugPrint(oldConstructionId)
        if type(oldConstructionId) ~= 'number' then return end
        if oldConstructionId < 0 then return end

        local oldConstruction = game.interface.getEntity(oldConstructionId)
        print('oldConstruction =')
        debugPrint(oldConstruction)

        local newId = game.interface.upgradeConstruction(
            oldConstruction.id,
            oldConstruction.fileName,
            -- leadingStation.params -- NO!
            arrayUtils.cloneOmittingFields(oldConstruction.params, {'seed'})
        )
        print('construction', oldConstructionId, 'upgraded to', newId or 'NIL')
    end,
    triggerUpdate4Town = function(townId)
        print('type(townId) = ', type(townId))
        print('townId = ', townId or 'NIL')
        if type(townId) ~= 'number' or townId < 1 then return end

        local townData = api.engine.getComponent(townId, api.type.ComponentType.TOWN)
        if not(townData) then return end

        -- res, com, ind.
        local oldCargoNeeds = townData.cargoNeeds
        if not(oldCargoNeeds) then return end

        -- local cargoSupplyAndLimit = api.engine.system.townBuildingSystem.getCargoSupplyAndLimit(townId)
        -- local newCargoNeeds = oldCargoNeeds
        -- for cargoTypeId, cargoSupply in pairs(cargoSupplyAndLimit) do
        --     print(cargoTypeId, cargoSupply)
        -- end
        api.cmd.sendCommand(
            -- this triggers updateFn for all the town buildings
            api.cmd.make.instantlyUpdateTownCargoNeeds(townId, oldCargoNeeds)
        )
    end,
    updateCapacityFactorValue = function(townId)
        if type(townId) ~= 'number' or townId < 1 then return end

        _state.townId4CapacityFactorNeedingUpdate = townId
    end,
    updateConsumptionFactorValue = function(townId)
        if type(townId) ~= 'number' or townId < 1 then return end

        _state.townId4ConsumptionFactorNeedingUpdate = townId
    end,
    updatePersonCapacityFactorValue = function(townId)
        if type(townId) ~= 'number' or townId < 1 then return end

        _state.townId4PersonCapacityFactorNeedingUpdate = townId
    end,
}
local _actions = {
    alterCapacityFactor = function(isUp)
        print('alterCapacityFactor starting, isCapacityFactorUp =', isUp)
        -- local buildings = api.engine.system.townBuildingSystem.getTown2BuildingMap()[townId]
        -- for _, buildingId in pairs(buildings) do
        --     _utils.replaceBuildingWithSelf_dumps(buildingId)
        -- end
print('commonData.common.get() before =')
debugPrint(commonData.common.get())
        commonData.common.setCapacityFactor(isUp)
print('commonData.common.get() after =')
debugPrint(commonData.common.get())
print('commonData.towns.get() after =')
debugPrint(commonData.towns.get())

        for townId, _ in pairs(commonData.towns.get()) do
            _utils.triggerUpdate4Town(townId)
        end
    end,
    alterCapacityFactorByTown = function(townId, isCapacityFactorUp)
        -- no good, call in a loop and you are in for a multithreading disaster
        print('alterCapacityFactorByTown starting, townId =', townId or 'NIL', 'isCapacityFactorUp =', isCapacityFactorUp or false)
        if type(townId) ~= 'number' or townId < 1 then return end

        commonData.common.setCapacityFactor(isCapacityFactorUp)

        local buildings = api.engine.system.townBuildingSystem.getTown2BuildingMap()[townId]
        print('#buildings =', #buildings)
        debugPrint(buildings)
        local i = 0
        for _, buildingId in pairs(buildings) do
            i = i + 1
            print('about to replace building no', i, 'with buildingId =')
            debugPrint(buildingId)
            _utils.replaceBuildingWithSelf(buildingId)
            print('building no', i, 'processed')
        end
        print('alterCapacityFactorByTown ending')
    end,
    alterConsumptionFactor = function(isUp)
        print('alterConsumptionFactor starting, isConsumptionFactorUp =', isUp)
        -- local buildings = api.engine.system.townBuildingSystem.getTown2BuildingMap()[townId]
        -- for _, buildingId in pairs(buildings) do
        --     _utils.replaceBuildingWithSelf_dumps(buildingId)
        -- end
print('commonData.common.get() before =')
debugPrint(commonData.common.get())
        commonData.common.setConsumptionFactor(isUp)
print('commonData.common.get() after =')
debugPrint(commonData.common.get())
print('commonData.towns.get() after =')
debugPrint(commonData.towns.get())

        for townId, _ in pairs(commonData.towns.get()) do
            _utils.triggerUpdate4Town(townId)
        end
    end,
    alterPersonCapacityFactor = function(isUp)
        print('alterPersonCapacityFactor starting, isPersonCapacityFactorUp =', isUp)
        -- local buildings = api.engine.system.townBuildingSystem.getTown2BuildingMap()[townId]
        -- for _, buildingId in pairs(buildings) do
        --     _utils.replaceBuildingWithSelf_dumps(buildingId)
        -- end
print('commonData.common.get() before =')
debugPrint(commonData.common.get())
        commonData.common.setPersonCapacityFactor(isUp)
print('commonData.common.get() after =')
debugPrint(commonData.common.get())
print('commonData.towns.get() after =')
debugPrint(commonData.towns.get())

        for townId, _ in pairs(commonData.towns.get()) do
            _utils.triggerUpdate4Town(townId)
        end
    end,
    alterTownRequirements = function(townId, consumptionFactorDelta)
        -- LOLLO TODO implement this and its UI
        print('alterTownRequirements starting, townId =', townId, 'consumptionFactorDelta =', consumptionFactorDelta)
        -- local buildings = api.engine.system.townBuildingSystem.getTown2BuildingMap()[townId]
        -- for _, buildingId in pairs(buildings) do
        --     _utils.replaceBuildingWithSelf_dumps(buildingId)
        -- end
        _utils.triggerUpdate4Town(townId)
    end,
}

function data()
    return {
        -- guiInit = function()
        --     -- create and initialize ui elements
        -- end,
        handleEvent = function(src, id, name, param)
            if (id ~= _eventId or type(param) ~= 'table') then return end

            if name == 'lolloTownTuning_CapacityFactorButtonDown' then
                _actions.alterCapacityFactor(false)
                -- _actions.alterCapacityFactorByTown(param.townId, false)
                _utils.updateCapacityFactorValue(param.townId)
            elseif name == 'lolloTownTuning_CapacityFactorButtonUp' then
                print('param.townId =')
                debugPrint(param.townId)
                _actions.alterCapacityFactor(true)
                -- _actions.alterCapacityFactorByTown(param.townId, true)
                _utils.updateCapacityFactorValue(param.townId)
            elseif name == 'lolloTownTuning_ConsumptionFactorButtonDown' then
                _actions.alterConsumptionFactor(false)
                _utils.updateConsumptionFactorValue(param.townId)
            elseif name == 'lolloTownTuning_ConsumptionFactorButtonUp' then
                _actions.alterConsumptionFactor(true)
                _utils.updateConsumptionFactorValue(param.townId)
            elseif name == 'lolloTownTuning_PersonCapacityFactorButtonDown' then
                _actions.alterPersonCapacityFactor(false)
                _utils.updatePersonCapacityFactorValue(param.townId)
            elseif name == 'lolloTownTuning_PersonCapacityFactorButtonUp' then
                _actions.alterPersonCapacityFactor(true)
                _utils.updatePersonCapacityFactorValue(param.townId)
            end
        end,
        guiHandleEvent = function(id, name, param)
            -- if you click on a town label, its stats will open.
            -- The game will raise select with a numeric id (eg 21550)
            -- and create a new window with the stats of a town.
            -- temp.view.entity_21550 will be the id of the temp town stats window.
            -- If you open the town stats menu, select won't fire.
            -- In both cases, idAdded will fire instead.
            if type(id) == 'string' then
                xpcall(
                    function()
                        if name == 'idAdded' and id:find('temp.view.entity_') then
                            for townId, townData in pairs(commonData.towns.get()) do
                                if townData.townStatWindowId == id then
                                    _utils.guiAddTownStatButtons(id, townId, commonData.common.get())
                                    break
                                end
                            end
                        elseif name == 'button.click' and id:find('lolloTownTuning_') then
                            if id:find('lolloTownTuning_CapacityFactorButtonDown_') then
                                print('LOLLO button down clicked; name, param =')
                                debugPrint(name)
                                debugPrint(param)
                                game.interface.sendScriptEvent(
                                    _eventId, -- id
                                    'lolloTownTuning_CapacityFactorButtonDown', -- name
                                    { -- param
                                        townId = tonumber(id:sub(id:find('_') + 1))
                                    }
                                )
                            elseif id:find('lolloTownTuning_CapacityFactorButtonUp_') then
                                print('LOLLO button up clicked; name, param =')
                                debugPrint(name)
                                debugPrint(param)
                                game.interface.sendScriptEvent(
                                    _eventId, -- id
                                    'lolloTownTuning_CapacityFactorButtonUp', -- name
                                    { -- param
                                        townId = tonumber(id:sub(id:find('_') + 1))
                                    }
                                )
                            elseif id:find('lolloTownTuning_ConsumptionFactorButtonDown_') then
                                print('LOLLO button down clicked; name, param =')
                                debugPrint(name)
                                debugPrint(param)
                                game.interface.sendScriptEvent(
                                    _eventId, -- id
                                    'lolloTownTuning_ConsumptionFactorButtonDown', -- name
                                    { -- param
                                        townId = tonumber(id:sub(id:find('_') + 1))
                                    }
                                )
                            elseif id:find('lolloTownTuning_ConsumptionFactorButtonUp_') then
                                print('LOLLO button up clicked; name, param =')
                                debugPrint(name)
                                debugPrint(param)
                                game.interface.sendScriptEvent(
                                    _eventId, -- id
                                    'lolloTownTuning_ConsumptionFactorButtonUp', -- name
                                    { -- param
                                        townId = tonumber(id:sub(id:find('_') + 1))
                                    }
                                )
                            elseif id:find('lolloTownTuning_PersonCapacityFactorButtonDown_') then
                                print('LOLLO button down clicked; name, param =')
                                debugPrint(name)
                                debugPrint(param)
                                game.interface.sendScriptEvent(
                                    _eventId, -- id
                                    'lolloTownTuning_PersonCapacityFactorButtonDown', -- name
                                    { -- param
                                        townId = tonumber(id:sub(id:find('_') + 1))
                                    }
                                )
                            elseif id:find('lolloTownTuning_PersonCapacityFactorButtonUp_') then
                                print('LOLLO button up clicked; name, param =')
                                debugPrint(name)
                                debugPrint(param)
                                game.interface.sendScriptEvent(
                                    _eventId, -- id
                                    'lolloTownTuning_PersonCapacityFactorButtonUp', -- name
                                    { -- param
                                        townId = tonumber(id:sub(id:find('_') + 1))
                                    }
                                )
                            end
                        end
                    end,
                    _myErrorHandler
            )
            end
        end,
        -- update = function()
        -- end,
        guiUpdate = function()
            _utils.guiUpdateCapacityFactorValue()
            _utils.guiUpdateConsumptionFactorValue()
            _utils.guiUpdatePersonCapacityFactorValue()
        end,
        load = function(data)
            if not(data) then return end

            _state.townId4CapacityFactorNeedingUpdate = data.townId4CapacityFactorNeedingUpdate or false
            _state.townId4ConsumptionFactorNeedingUpdate = data.townId4ConsumptionFactorNeedingUpdate or false
            _state.townId4PersonCapacityFactorNeedingUpdate = data.townId4PersonCapacityFactorNeedingUpdate or false
        end,
        save = function()
            if not _state then _state = {} end
            return _state
        end,
    }
end

