local arrayUtils = require('lollo_building_tuning.arrayUtils')
local commonData = require('lollo_building_tuning.commonData')

local function _myErrorHandler(err)
    print('lollo town tuning caught error: ', err)
end

local _areaTypes = {
    res = {
        id = 'res',
        index = 1,
        text = _('Residential')
    },
    com = {
        id = 'com',
        index = 2,
        text = _('Commercial')
    },
    ind = {
        id = 'ind',
        index = 3,
        text = _('Industrial')
    }
}

local _defaultCapacityFactor = commonData.defaultCapacityFactor
local _defaultConsumptionFactor = commonData.defaultConsumptionFactor
local _defaultPersonCapacityFactor = commonData.defaultPersonCapacityFactor

local _eventId = '__lolloTownTuningEvent__'
local _eventNames = {
    -- changeCapacityFactor = 'changeCapacityFactor',
    -- changeConsumptionFactor = 'changeConsumptionFactor',
    -- changePersonCapacityFactor = 'changePersonCapacityFactor',
    -- changeCargoNeeds = 'changeCargoNeeds',
    updateState = 'updateState',
}

local state = nil

local _dataHelper = { }
_dataHelper.cargoTypes = {
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
}
_dataHelper.shared = {
    get = function()
        local result = arrayUtils.cloneOmittingFields(state)
        if type(result) ~= 'table' then
            result = {
                capacityFactor = _defaultCapacityFactor,
                consumptionFactor = _defaultConsumptionFactor,
                personCapacityFactor = _defaultPersonCapacityFactor
            }
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

        local newCommon = arrayUtils.cloneOmittingFields(state)
        if type(newCommon.capacityFactor) ~= 'number' then
            newCommon.capacityFactor = _defaultCapacityFactor
        end

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
        api.cmd.sendCommand(api.cmd.make.sendScriptEvent(
            string.sub(debug.getinfo(1, 'S').source, 1),
            _eventId,
            _eventNames.updateState,
            arrayUtils.cloneOmittingFields(newCommon)
        ))
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

        local newCommon = arrayUtils.cloneOmittingFields(state)
        if type(newCommon.consumptionFactor) ~= 'number' then
            newCommon.consumptionFactor = _defaultConsumptionFactor end

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
        api.cmd.sendCommand(api.cmd.make.sendScriptEvent(
            string.sub(debug.getinfo(1, 'S').source, 1),
            _eventId,
            _eventNames.updateState,
            arrayUtils.cloneOmittingFields(newCommon)
        ))
    end,
    getPersonCapacityFactorIndex = function(factor)
        if type(factor) ~= 'number' then
            factor = _defaultPersonCapacityFactor
        end

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

        local newCommon = arrayUtils.cloneOmittingFields(state)
        if type(newCommon.personCapacityFactor) ~= 'number' then
            newCommon.personCapacityFactor = _defaultPersonCapacityFactor
        end

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
        api.cmd.sendCommand(api.cmd.make.sendScriptEvent(
            string.sub(debug.getinfo(1, 'S').source, 1),
            _eventId,
            _eventNames.updateState,
            arrayUtils.cloneOmittingFields(newCommon)
        ))
    end,
}
_dataHelper.towns = {
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
}

local _utils = {
    findIndex = function(tab, fieldValueNonNil)
        if fieldValueNonNil == nil then return -1 end

        for i = 1, #tab do
            if tab[i] == fieldValueNonNil then
                return i
            end
        end

        return -1
    end,
}
local _actions = {}
_actions.guiAddOneTownProps = function(parentLayout, townId)
    if type(townId) ~= 'number' or townId < 1 then return end

    local townData = api.engine.getComponent(townId, api.type.ComponentType.TOWN)
    if not(townData) then return end

    local cargoTypes = _dataHelper.cargoTypes.getAll()
    local cargoTypesGuiTable = api.gui.comp.Table.new(#cargoTypes + 1, 'NONE')
    cargoTypesGuiTable:setNumCols(3)
    cargoTypesGuiTable:addRow({
        api.gui.comp.TextView.new(_areaTypes.res.text),
        api.gui.comp.TextView.new(_areaTypes.com.text),
        api.gui.comp.TextView.new(_areaTypes.ind.text)
    })
    for cargoTypeId, cargoData in pairs(cargoTypes) do
        local resComp = api.gui.comp.Component.new(_areaTypes.res.id)
        resComp:setLayout(api.gui.layout.BoxLayout.new('HORIZONTAL'))
        resComp:getLayout():addItem(api.gui.comp.ImageView.new(cargoData.icon)) -- iconSmall
        local resCheckBox = api.gui.comp.CheckBox.new('', 'ui/checkbox0.tga', 'ui/checkbox1.tga')
        -- resCheckBox:setId('lolloTownTuning_town_' .. tostring(townId) .. '_resCargoType_' .. tostring(cargoTypeId))
        resCheckBox:onToggle(
            function(newValue)
                cargoTypesGuiTable:setEnabled(false)
                _actions.triggerUpdateTownCargoNeeds(townId, _areaTypes.res.index, cargoTypeId, newValue)
                cargoTypesGuiTable:setEnabled(true)
            end
        )
        for _, v in pairs(townData.cargoNeeds[1]) do
            if v == cargoTypeId then resCheckBox:setSelected(true, false) end
        end
        resComp:getLayout():addItem(resCheckBox)

        local comComp = api.gui.comp.Component.new(_areaTypes.com.id)
        comComp:setLayout(api.gui.layout.BoxLayout.new('HORIZONTAL'))
        comComp:getLayout():addItem(api.gui.comp.ImageView.new(cargoData.icon))
        local comCheckBox = api.gui.comp.CheckBox.new('', 'ui/checkbox0.tga', 'ui/checkbox1.tga')
        -- comCheckBox:setId('lolloTownTuning_town_' .. tostring(townId) .. '_comCargoType_' .. tostring(cargoTypeId))
        comCheckBox:onToggle(
            function(newValue)
                cargoTypesGuiTable:setEnabled(false)
                _actions.triggerUpdateTownCargoNeeds(townId, _areaTypes.com.index, cargoTypeId, newValue)
                cargoTypesGuiTable:setEnabled(true)
            end
        )
        for _, v in pairs(townData.cargoNeeds[2]) do
            if v == cargoTypeId then comCheckBox:setSelected(true, false) end
        end
        comComp:getLayout():addItem(comCheckBox)

        local indComp = api.gui.comp.Component.new(_areaTypes.ind.id)
        indComp:setLayout(api.gui.layout.BoxLayout.new('HORIZONTAL'))
        indComp:getLayout():addItem(api.gui.comp.ImageView.new(cargoData.icon))
        local indCheckBox = api.gui.comp.CheckBox.new('', 'ui/checkbox0.tga', 'ui/checkbox1.tga')
        -- indCheckBox:setId('lolloTownTuning_town_' .. tostring(townId) .. '_indCargoType_' .. tostring(cargoTypeId))
        indCheckBox:onToggle(
            function(newValue)
                cargoTypesGuiTable:setEnabled(false)
                _actions.triggerUpdateTownCargoNeeds(townId, _areaTypes.ind.index, cargoTypeId, newValue)
                cargoTypesGuiTable:setEnabled(true)
            end
        )
        for _, v in pairs(townData.cargoNeeds[3]) do
            if v == cargoTypeId then indCheckBox:setSelected(true, false) end
        end
        indComp:getLayout():addItem(indCheckBox)

        cargoTypesGuiTable:addRow({resComp, comComp, indComp})
    end

    parentLayout:addItem(cargoTypesGuiTable)
end
_actions.guiAddAllTownProps = function(parentLayout, townId)
    local sharedData = _dataHelper.shared.get()

    local capacityTextViewTitle = api.gui.comp.TextView.new(_('CAPACITY_FACTOR'))
    local capacityToggleButtons = {}
    capacityToggleButtons[1] = api.gui.comp.ToggleButton.new(api.gui.comp.TextView.new("--"))
    capacityToggleButtons[2] = api.gui.comp.ToggleButton.new(api.gui.comp.TextView.new("-"))
    capacityToggleButtons[3] = api.gui.comp.ToggleButton.new(api.gui.comp.TextView.new("0"))
    capacityToggleButtons[4] = api.gui.comp.ToggleButton.new(api.gui.comp.TextView.new("+"))
    capacityToggleButtons[5] = api.gui.comp.ToggleButton.new(api.gui.comp.TextView.new("++"))
    local capacityToggleButtonGroup = api.gui.comp.ToggleButtonGroup.new(api.gui.util.Alignment.HORIZONTAL, 0, false)
    capacityToggleButtonGroup:setOneButtonMustAlwaysBeSelected(true)
    capacityToggleButtonGroup:setEmitSignal(false)
    capacityToggleButtonGroup:onCurrentIndexChanged(
        function(newIndexBase0)
            capacityToggleButtonGroup:setEnabled(false)
            _dataHelper.shared.setCapacityFactor(newIndexBase0 + 1)
            for townId_, _ in pairs(_dataHelper.towns.get()) do
                _actions.triggerUpdateTown(townId_)
            end
            capacityToggleButtonGroup:setEnabled(true)
        end
    )
    for i = 1, #capacityToggleButtons do
        capacityToggleButtonGroup:add(capacityToggleButtons[i])
    end
    capacityToggleButtons[_dataHelper.shared.getCapacityFactorIndex(sharedData.capacityFactor)]:setSelected(true, false)

    local consumptionTextViewTitle = api.gui.comp.TextView.new(_('CONSUMPTION_FACTOR'))
    local consumptionToggleButtons = {}
    consumptionToggleButtons[1] = api.gui.comp.ToggleButton.new(api.gui.comp.TextView.new("--"))
    consumptionToggleButtons[2] = api.gui.comp.ToggleButton.new(api.gui.comp.TextView.new("-"))
    consumptionToggleButtons[3] = api.gui.comp.ToggleButton.new(api.gui.comp.TextView.new("0"))
    consumptionToggleButtons[4] = api.gui.comp.ToggleButton.new(api.gui.comp.TextView.new("+"))
    consumptionToggleButtons[5] = api.gui.comp.ToggleButton.new(api.gui.comp.TextView.new("++"))
    local consumptionToggleButtonGroup = api.gui.comp.ToggleButtonGroup.new(api.gui.util.Alignment.HORIZONTAL, 0, false)
    consumptionToggleButtonGroup:setOneButtonMustAlwaysBeSelected(true)
    consumptionToggleButtonGroup:setEmitSignal(false)
    consumptionToggleButtonGroup:onCurrentIndexChanged(
        function(newIndexBase0)
            consumptionToggleButtonGroup:setEnabled(false)
            _dataHelper.shared.setConsumptionFactor(newIndexBase0 + 1)
            for townId_, _ in pairs(_dataHelper.towns.get()) do
                _actions.triggerUpdateTown(townId_)
            end
            consumptionToggleButtonGroup:setEnabled(true)
        end
    )
    for i = 1, #consumptionToggleButtons do
        consumptionToggleButtonGroup:add(consumptionToggleButtons[i])
    end
    consumptionToggleButtons[_dataHelper.shared.getConsumptionFactorIndex(sharedData.consumptionFactor)]:setSelected(true, false)

    local personCapacityTextViewTitle = api.gui.comp.TextView.new(_('PERSON_CAPACITY_FACTOR'))
    local personCapacityToggleButtons = {}
    personCapacityToggleButtons[1] = api.gui.comp.ToggleButton.new(api.gui.comp.TextView.new("--"))
    personCapacityToggleButtons[2] = api.gui.comp.ToggleButton.new(api.gui.comp.TextView.new("-"))
    personCapacityToggleButtons[3] = api.gui.comp.ToggleButton.new(api.gui.comp.TextView.new("0"))
    personCapacityToggleButtons[4] = api.gui.comp.ToggleButton.new(api.gui.comp.TextView.new("+"))
    personCapacityToggleButtons[5] = api.gui.comp.ToggleButton.new(api.gui.comp.TextView.new("++"))
    local personCapacityToggleButtonGroup = api.gui.comp.ToggleButtonGroup.new(api.gui.util.Alignment.HORIZONTAL, 0, false)
    personCapacityToggleButtonGroup:setOneButtonMustAlwaysBeSelected(true)
    personCapacityToggleButtonGroup:setEmitSignal(false)
    personCapacityToggleButtonGroup:onCurrentIndexChanged(
        function(newIndexBase0)
            personCapacityToggleButtonGroup:setEnabled(false)
            _dataHelper.shared.setPersonCapacityFactor(newIndexBase0 + 1)
            for townId_, _ in pairs(_dataHelper.towns.get()) do
                _actions.triggerUpdateTown(townId_)
            end
            personCapacityToggleButtonGroup:setEnabled(true)
        end
    )
    for i = 1, #personCapacityToggleButtons do
        personCapacityToggleButtonGroup:add(personCapacityToggleButtons[i])
    end
    personCapacityToggleButtons[_dataHelper.shared.getPersonCapacityFactorIndex(sharedData.personCapacityFactor)]:setSelected(true, false)

    parentLayout:addItem(capacityTextViewTitle)
    parentLayout:addItem(capacityToggleButtonGroup)
    parentLayout:addItem(consumptionTextViewTitle)
    parentLayout:addItem(consumptionToggleButtonGroup)
    parentLayout:addItem(personCapacityTextViewTitle)
    parentLayout:addItem(personCapacityToggleButtonGroup)
end
_actions.guiAddTuningMenu = function(windowId, townId)
    local window = api.gui.util.getById(windowId)
    window:setResizable(true)

    local windowContent = window:getContent()
    local tuningTab = api.gui.comp.Component.new('TUNING')
    tuningTab:setLayout(api.gui.layout.BoxLayout.new('VERTICAL'))
    windowContent:insertTab(
        api.gui.comp.TextView.new(_('TUNING_TAB_LABEL')),
        tuningTab,
        3
    )
    local tuningLayout = tuningTab:getLayout()
    _actions.guiAddAllTownProps(tuningLayout, townId)
    _actions.guiAddOneTownProps(tuningLayout, townId)

    local minimumSize = window:calcMinimumSize()
    local newSize = api.gui.util.Size.new()
    newSize.h = minimumSize.h + 250
    newSize.w = minimumSize.w + 100
    -- window:setMinimumSize(newSize) -- useless
    window:setSize(newSize) -- flickers if h is too small
    -- window:setMaximiseSize(newSize.w, newSize.h, 1) -- flickers if h is too small, could be useful tho
end
_actions.replaceBuildingWithSelf = function(oldBuildingId)
    -- no good, leads to multithreading nightmare
    if type(oldBuildingId) ~= 'number' or oldBuildingId < 0 then return end

    local oldBuilding = api.engine.getComponent(oldBuildingId, api.type.ComponentType.TOWN_BUILDING)
    if not(oldBuilding) then return end
    -- skip buildings that do not accept freight
    if not(oldBuilding.personCapacity) then return end
    if type(oldBuilding.stockList) ~= 'number' then return end
    if oldBuilding.stockList < 0 then return end
    local oldConstructionId = oldBuilding.personCapacity -- whatever they were thinking
    if type(oldConstructionId) ~= 'number' then return end
    if oldConstructionId < 0 then return end

    local oldConstruction = game.interface.getEntity(oldConstructionId)

    local newId = game.interface.upgradeConstruction(
        oldConstruction.id,
        oldConstruction.fileName,
        -- leadingStation.params -- NO!
        arrayUtils.cloneOmittingFields(oldConstruction.params, {'seed'})
    )
end
_actions.triggerUpdateTown = function(townId)
    if type(townId) ~= 'number' or townId < 1 then return end

    local townData = api.engine.getComponent(townId, api.type.ComponentType.TOWN)
    if not(townData) then return end

    -- res, com, ind
    local cargoNeeds = townData.cargoNeeds
    if not(cargoNeeds) then return end

    -- local cargoSupplyAndLimit = api.engine.system.townBuildingSystem.getCargoSupplyAndLimit(townId)
    -- local newCargoNeeds = oldCargoNeeds
    -- for cargoTypeId, cargoSupply in pairs(cargoSupplyAndLimit) do
    --     print(cargoTypeId, cargoSupply)
    -- end
    api.cmd.sendCommand(
        -- this triggers updateFn for all the town buildings
        api.cmd.make.instantlyUpdateTownCargoNeeds(townId, cargoNeeds)
    )
end
_actions.triggerUpdateTownCargoNeeds = function(townId, areaTypeIndex, cargoTypeId, newValue)
    if type(townId) ~= 'number' or townId < 1 then return end

    local townData = api.engine.getComponent(townId, api.type.ComponentType.TOWN)
    if not(townData) then return end

    -- res, com, ind
    local cargoNeeds = townData.cargoNeeds
    if not(cargoNeeds) then return end

    if newValue then
        if not(arrayUtils.arrayHasValue(cargoNeeds[areaTypeIndex], cargoTypeId)) then
            cargoNeeds[areaTypeIndex][#cargoNeeds[areaTypeIndex] + 1] = cargoTypeId
        end
    else
        local index = _utils.findIndex(cargoNeeds[areaTypeIndex], cargoTypeId)
        if index > -1 then
            cargoNeeds[areaTypeIndex][index] = nil
        end
    end

    api.cmd.sendCommand(
        -- this triggers updateFn for all the town buildings
        api.cmd.make.instantlyUpdateTownCargoNeeds(townId, cargoNeeds)
    )
end

function data()
    return {
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
                            for townId, townData in pairs(_dataHelper.towns.get()) do
                                if townData.townStatWindowId == id then
                                    _actions.guiAddTuningMenu(id, townId)
                                    break
                                end
                            end
                        end
                    end,
                    _myErrorHandler
            )
            end
        end,
        handleEvent = function(src, id, name, params)
            if id == _eventId then
                if name == _eventNames.updateState then
                    state = params -- LOLLO NOTE you can only update the state from the worker thread
                end
            end
        end,
        save = function()
            -- only fires when the worker thread changes the state
            if not state then state = {} end
            if not state.capacityFactor then state.capacityFactor = _defaultCapacityFactor end
            if not state.consumptionFactor then state.consumptionFactor = _defaultConsumptionFactor end
            if not state.personCapacityFactor then state.personCapacityFactor = _defaultPersonCapacityFactor end
            return state
        end,
        load = function(loadedState)
            -- fires once in the worker thread, at game load, and many times in the UI thread
            if loadedState then
                state = {}
                state.capacityFactor = loadedState.capacityFactor or _defaultCapacityFactor
                state.consumptionFactor = loadedState.consumptionFactor or _defaultConsumptionFactor
                state.personCapacityFactor = loadedState.personCapacityFactor or _defaultPersonCapacityFactor
            else
                state = {
                    capacityFactor = _defaultCapacityFactor,
                    consumptionFactor = _defaultConsumptionFactor,
                    personCapacityFactor = _defaultPersonCapacityFactor
                }
            end
            commonData.set(state)
        end,
    }
end
