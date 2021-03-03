local arrayUtils = require('lollo_town_tuning.arrayUtils')
local commonData = require('lollo_town_tuning.commonData')
local logger = require('lollo_town_tuning.logger')

local function _myErrorHandler(err)
    print('lollo town tuning caught error: ', err)
end

-- LOLLO NOTE you can update town sizes with
-- api.cmd.sendCommand(api.cmd.make.setTownInfo(townId, {resCapa, comCapa, indCapa}))
-- This will not add anything to the sandbox menu
-- and its results will be adjusted to fall within the limits:
-- min is 50, max is 800.
-- However, this only applies to the display in the "editor" tab.
-- Make your own control and you can grow and shrink the town beyond those limits!

local _areaTypes = {
    res = {
        id = 'res',
        index = 1,
        initialCapaText = _('INITIAL_RES_CAPACITY'),
        text = _('Residential')
    },
    com = {
        id = 'com',
        index = 2,
        initialCapaText = _('INITIAL_COM_CAPACITY'),
        text = _('Commercial')
    },
    ind = {
        id = 'ind',
        index = 3,
        initialCapaText = _('INITIAL_IND_CAPACITY'),
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

-- these 3 text fields are global so they can update when the API has run
local _guiResOutput = nil -- api.gui.comp.TextView.new('')
local _guiComOutput = nil -- api.gui.comp.TextView.new('')
local _guiIndOutput = nil -- api.gui.comp.TextView.new('')

local _townInitialLandUseCapacities = {
    bigStep = 500,
    max = 5000,
    min = 0,
    step = 50,
}
local state = nil

local _dataHelper = {
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
        local result = arrayUtils.cloneDeepOmittingFields(state)
        if type(result) ~= 'table' then
            -- print('sharedData found no state, returning defaults')
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

        local result = 4
        if factor <= 0.1 then
            result = 1
        elseif factor == 0.25 then
            result = 2
        elseif factor == 0.5 then
            result = 3
        elseif factor == 1.5 then
            result = 5
        elseif factor >= 2 then
            result = 6
        end

        return result
    end,
    setCapacityFactor = function(index)
        if type(index) ~= 'number' then return false end

        local newCommon = arrayUtils.cloneDeepOmittingFields(state)
        if type(newCommon.capacityFactor) ~= 'number' then
            newCommon.capacityFactor = _defaultCapacityFactor
        end

        local newFactor = _defaultCapacityFactor
        if index <= 1 then
            newFactor = 0.1
        elseif index == 2 then
            newFactor = 0.25
        elseif index == 3 then
            newFactor = 0.5
        elseif index == 5 then
            newFactor = 1.5
        elseif index >= 6 then
            newFactor = 2.0
        end

        if newFactor == newCommon.capacityFactor then return false end

        newCommon.capacityFactor = newFactor
        api.cmd.sendCommand(api.cmd.make.sendScriptEvent(
            string.sub(debug.getinfo(1, 'S').source, 1),
            _eventId,
            _eventNames.updateState,
            arrayUtils.cloneDeepOmittingFields(newCommon)
        ))

        return true
    end,
    getConsumptionFactorIndex = function(factor)
        if type(factor) ~= 'number' then factor = _defaultConsumptionFactor end

        local result = 3
        if factor <= 0.3 then
            result = 1
        elseif factor == 0.6 then
            result = 2
        elseif factor == 1.8 then
            result = 4
        elseif factor == 2.4 then
            result = 5
        elseif factor >= 3.0 then
            result = 6
        end

        return result
    end,
    setConsumptionFactor = function(index)
        if type(index) ~= 'number' then return false end

        local newCommon = arrayUtils.cloneDeepOmittingFields(state)
        if type(newCommon.consumptionFactor) ~= 'number' then
            newCommon.consumptionFactor = _defaultConsumptionFactor
        end

        local newFactor = _defaultConsumptionFactor
        if index <= 1 then
            newFactor = 0.3
        elseif index == 2 then
            newFactor = 0.6
        elseif index == 4 then
            newFactor = 1.8
        elseif index == 5 then
            newFactor = 2.4
        elseif index >= 6 then
            newFactor = 4.8
        end

        if newFactor == newCommon.consumptionFactor then return false end

        newCommon.consumptionFactor = newFactor
        api.cmd.sendCommand(api.cmd.make.sendScriptEvent(
            string.sub(debug.getinfo(1, 'S').source, 1),
            _eventId,
            _eventNames.updateState,
            arrayUtils.cloneDeepOmittingFields(newCommon)
        ))

        return true
    end,
    getPersonCapacityFactorIndex = function(factor)
        if type(factor) ~= 'number' then
            factor = _defaultPersonCapacityFactor
        end

        local result = 4
        if factor <= 0.1 then
            result = 1
        elseif factor == 0.25 then
            result = 2
        elseif factor == 0.5 then
            result = 3
        elseif factor == 1.5 then
            result = 5
        elseif factor >= 2.0 then
            result = 6
        end

        return result
    end,
    setPersonCapacityFactor = function(index)
        if type(index) ~= 'number' then return false end

        local newCommon = arrayUtils.cloneDeepOmittingFields(state)
        if type(newCommon.personCapacityFactor) ~= 'number' then
            newCommon.personCapacityFactor = _defaultPersonCapacityFactor
        end

        local newFactor = _defaultPersonCapacityFactor
        if index <= 1 then
            newFactor = 0.1
        elseif index == 2 then
            newFactor = 0.25
        elseif index == 3 then
            newFactor = 0.5
        elseif index == 5 then
            newFactor = 1.5
        elseif index >= 6 then
            newFactor = 2.0
        end

        if newFactor == newCommon.personCapacityFactor then return false end

        newCommon.personCapacityFactor = newFactor
        api.cmd.sendCommand(api.cmd.make.sendScriptEvent(
            string.sub(debug.getinfo(1, 'S').source, 1),
            _eventId,
            _eventNames.updateState,
            arrayUtils.cloneDeepOmittingFields(newCommon)
        ))

        return true
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
    },
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
    getCargoNeeds = function(townId)
        if type(townId) ~= 'number' or townId < 1 then return nil end

        local townData = api.engine.getComponent(townId, api.type.ComponentType.TOWN)
        if not(townData) then return nil end

        -- local cargoSupplyAndLimit = api.engine.system.townBuildingSystem.getCargoSupplyAndLimit(townId)
        -- local newCargoNeeds = oldCargoNeeds
        -- for cargoTypeId, cargoSupply in pairs(cargoSupplyAndLimit) do
        --     print(cargoTypeId, cargoSupply)
        -- end

        -- res, com, ind
        return townData.cargoNeeds
    end
}
local _actions = {}
_actions.guiAddOneTownProps = function(parentLayout, townId)
    if type(townId) ~= 'number' or townId < 1 then return end
    logger.print('townId =', townId or 'NIL')

    local townData = api.engine.getComponent(townId, api.type.ComponentType.TOWN)
    if not(townData) then return end

    local _addInitialLandUseCapacities = function()
        local _getField = function(resComInd)
            local inputField = api.gui.comp.Slider.new(true)
            inputField:setMaximum(_townInitialLandUseCapacities.max)
            inputField:setMinimum(_townInitialLandUseCapacities.min)
            inputField:setPageStep(_townInitialLandUseCapacities.bigStep)
            inputField:setStep(_townInitialLandUseCapacities.step)
            inputField:setValue(townData.initialLandUseCapacities[resComInd], false)
            local size = api.gui.util.Size.new() size.w = 600
            inputField:setMinimumSize(size)
            return inputField
        end

        local townInitialLandUseCapacitiesList = api.gui.comp.Component.new('townInitialLandUseCapacitiesList') -- _areaTypes.res.id)
        townInitialLandUseCapacitiesList:setLayout(api.gui.layout.BoxLayout.new('VERTICAL'))

        townInitialLandUseCapacitiesList:getLayout():addItem(api.gui.comp.TextView.new(_areaTypes.res.initialCapaText))
        local resInput = _getField(1)
        _guiResOutput:setText(tostring(resInput:getValue()))
        townInitialLandUseCapacitiesList:getLayout():addItem(resInput)
        townInitialLandUseCapacitiesList:getLayout():addItem(_guiResOutput)
        resInput:onValueChanged(
            function(newValue)
                logger.print('newValue =', type(newValue)) logger.debugPrint(newValue)
                _actions.triggerUpdateTownInitialLandUse(townId, newValue, 1)
            end
        )

        townInitialLandUseCapacitiesList:getLayout():addItem(api.gui.comp.TextView.new(_areaTypes.com.initialCapaText))
        local comInput = _getField(2)
        _guiComOutput:setText(tostring(comInput:getValue()))
        townInitialLandUseCapacitiesList:getLayout():addItem(comInput)
        townInitialLandUseCapacitiesList:getLayout():addItem(_guiComOutput)
        comInput:onValueChanged(
            function(newValue)
                logger.print('newValue =', type(newValue)) logger.debugPrint(newValue)
                _actions.triggerUpdateTownInitialLandUse(townId, newValue, 2)
            end
        )

        townInitialLandUseCapacitiesList:getLayout():addItem(api.gui.comp.TextView.new(_areaTypes.ind.initialCapaText))
        local indInput = _getField(3)
        _guiIndOutput:setText(tostring(indInput:getValue()))
        townInitialLandUseCapacitiesList:getLayout():addItem(indInput)
        townInitialLandUseCapacitiesList:getLayout():addItem(_guiIndOutput)
        indInput:onValueChanged(
            function(newValue)
                logger.print('newValue =', type(newValue)) logger.debugPrint(newValue)
                _actions.triggerUpdateTownInitialLandUse(townId, newValue, 3)
            end
        )

        return townInitialLandUseCapacitiesList
    end
    parentLayout:addItem(_addInitialLandUseCapacities())

    local _addRequirements = function()
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
        return cargoTypesGuiTable
    end
    parentLayout:addItem(_addRequirements())

end

_actions.guiAddAllTownProps = function(parentLayout)
    local sharedData = _dataHelper.shared.get()

    local capacityTextViewTitle = api.gui.comp.TextView.new(_('CAPACITY_FACTOR'))
    local capacityToggleButtons = {}
    capacityToggleButtons[1] = api.gui.comp.ToggleButton.new(api.gui.comp.TextView.new("---"))
    capacityToggleButtons[2] = api.gui.comp.ToggleButton.new(api.gui.comp.TextView.new("--"))
    capacityToggleButtons[3] = api.gui.comp.ToggleButton.new(api.gui.comp.TextView.new("-"))
    capacityToggleButtons[4] = api.gui.comp.ToggleButton.new(api.gui.comp.TextView.new("0"))
    capacityToggleButtons[5] = api.gui.comp.ToggleButton.new(api.gui.comp.TextView.new("+"))
    capacityToggleButtons[6] = api.gui.comp.ToggleButton.new(api.gui.comp.TextView.new("++"))
    local capacityToggleButtonGroup = api.gui.comp.ToggleButtonGroup.new(api.gui.util.Alignment.HORIZONTAL, 0, false)
    capacityToggleButtonGroup:setOneButtonMustAlwaysBeSelected(true)
    capacityToggleButtonGroup:setEmitSignal(false)
    capacityToggleButtonGroup:onCurrentIndexChanged(
        function(newIndexBase0)
            _dataHelper.shared.setCapacityFactor(newIndexBase0 + 1)
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
    consumptionToggleButtons[6] = api.gui.comp.ToggleButton.new(api.gui.comp.TextView.new("+++"))
    local consumptionToggleButtonGroup = api.gui.comp.ToggleButtonGroup.new(api.gui.util.Alignment.HORIZONTAL, 0, false)
    consumptionToggleButtonGroup:setOneButtonMustAlwaysBeSelected(true)
    consumptionToggleButtonGroup:setEmitSignal(false)
    consumptionToggleButtonGroup:onCurrentIndexChanged(
        function(newIndexBase0)
            _dataHelper.shared.setConsumptionFactor(newIndexBase0 + 1)
        end
    )
    for i = 1, #consumptionToggleButtons do
        consumptionToggleButtonGroup:add(consumptionToggleButtons[i])
    end
    consumptionToggleButtons[_dataHelper.shared.getConsumptionFactorIndex(sharedData.consumptionFactor)]:setSelected(true, false)

    local personCapacityTextViewTitle = api.gui.comp.TextView.new(_('PERSON_CAPACITY_FACTOR'))
    local personCapacityToggleButtons = {}
    personCapacityToggleButtons[1] = api.gui.comp.ToggleButton.new(api.gui.comp.TextView.new("---"))
    personCapacityToggleButtons[2] = api.gui.comp.ToggleButton.new(api.gui.comp.TextView.new("--"))
    personCapacityToggleButtons[3] = api.gui.comp.ToggleButton.new(api.gui.comp.TextView.new("-"))
    personCapacityToggleButtons[4] = api.gui.comp.ToggleButton.new(api.gui.comp.TextView.new("0"))
    personCapacityToggleButtons[5] = api.gui.comp.ToggleButton.new(api.gui.comp.TextView.new("+"))
    personCapacityToggleButtons[6] = api.gui.comp.ToggleButton.new(api.gui.comp.TextView.new("++"))
    local personCapacityToggleButtonGroup = api.gui.comp.ToggleButtonGroup.new(api.gui.util.Alignment.HORIZONTAL, 0, false)
    personCapacityToggleButtonGroup:setOneButtonMustAlwaysBeSelected(true)
    personCapacityToggleButtonGroup:setEmitSignal(false)
    personCapacityToggleButtonGroup:onCurrentIndexChanged(
        function(newIndexBase0)
            _dataHelper.shared.setPersonCapacityFactor(newIndexBase0 + 1)
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
    -- these 3 must be inited in the UI thread
    _guiResOutput = api.gui.comp.TextView.new('')
    _guiComOutput = api.gui.comp.TextView.new('')
    _guiIndOutput = api.gui.comp.TextView.new('')

    logger.print('windowId =', windowId or 'NIL')
    local window = api.gui.util.getById(windowId)
    window:setResizable(true)

    local minSize = api.gui.util.Size.new() minSize.h = 1000 minSize.w = 800
    window:setSize(minSize)

    local windowContent = window:getContent()
    -- remove the "editor" tab if in sandbox mode
    if windowContent:getNumTabs() > 3 then
        local editorTab = windowContent:getTab(3)
        editorTab:setVisible(false, false) -- does not work
        editorTab:setEnabled(false) -- at least this works
    end

    local tuningTab = api.gui.comp.Component.new('TUNING')
    tuningTab:setLayout(api.gui.layout.BoxLayout.new('VERTICAL'))
    windowContent:insertTab(
        api.gui.comp.TextView.new(_('TUNING_TAB_LABEL')),
        tuningTab,
        3
    )
    local tuningLayout = tuningTab:getLayout()
    _actions.guiAddAllTownProps(tuningLayout)
    _actions.guiAddOneTownProps(tuningLayout, townId)

    -- local minimumSize = window:calcMinimumSize()
    -- local newSize = api.gui.util.Size.new()
    -- newSize.h = minimumSize.h + 250
    -- newSize.w = minimumSize.w + 500
    -- -- window:setMinimumSize(newSize) -- useless
    -- window:setSize(newSize) -- flickers if h is too small
    -- window:setMaximiseSize(newSize.w, newSize.h, 1) -- flickers if h is too small, could be useful tho
end

_actions.triggerUpdateTown = function(townId)
    local cargoNeeds = _utils.getCargoNeeds(townId)
    if not(cargoNeeds) then return end

    api.cmd.sendCommand(
        -- this triggers updateFn for all the town buildings
        api.cmd.make.instantlyUpdateTownCargoNeeds(townId, cargoNeeds)
    )
end

_actions.triggerUpdateTownCargoNeeds = function(townId, areaTypeIndex, cargoTypeId, newValue)
    local cargoNeeds = _utils.getCargoNeeds(townId)
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

_actions.triggerUpdateTownInitialLandUse = function(townId, newCapa, resComInd)
    local townData = api.engine.getComponent(townId, api.type.ComponentType.TOWN)
    local resCapa = resComInd == 1 and newCapa or townData.initialLandUseCapacities[1]
    local comCapa = resComInd == 2 and newCapa or townData.initialLandUseCapacities[2]
    local indCapa = resComInd == 3 and newCapa or townData.initialLandUseCapacities[3]

    api.cmd.sendCommand(
        -- this won't trigger updateFn for all the town buildings
        api.cmd.make.setTownInfo(townId, {resCapa, comCapa, indCapa}),
        function(result, success)
            logger.print('setTownInfo callback, success =', success)
            logger.debugPrint(result)
            if success and result and result.initialLandUseCapacities then
                _guiResOutput:setText(tostring(result.initialLandUseCapacities[1]))
                _guiComOutput:setText(tostring(result.initialLandUseCapacities[2]))
                _guiIndOutput:setText(tostring(result.initialLandUseCapacities[3]))
            end
        end
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
        -- guiInit = function()
        -- fires once on start, it seems to fire after the worker thread fired save()
        --     logger.print('guiInit firing')
        -- end,
        -- guiUpdate = function()
        -- fires at intervals in the gui thread
        -- end,
        handleEvent = function(src, id, name, params)
            -- if src == 'guidesystem.lua' then return end
            -- print('handleEvent caught event with id =', id, 'src =', src, 'name =', name)
            if id == _eventId then
                if name == _eventNames.updateState then -- user pressed one of the "all towns" buttons
                    commonData.set(arrayUtils.cloneDeepOmittingFields(params)) -- do this now, the other thread might take too long
                    state = arrayUtils.cloneDeepOmittingFields(params) -- LOLLO NOTE you can only update the state from the worker thread
                    -- print('state updated, new state =')
                    -- debugPrint(state)

                    -- logger.print('timer =', os.time())
                    for townId_, _ in pairs(_dataHelper.towns.get()) do
                        _actions.triggerUpdateTown(townId_)
                    end
                    logger.print('update triggered for all towns')
                    -- logger.print('timer now =', os.time()) nearly instant or useless
                end
            end
        end,
        load = function(loadedState)
            -- fires once in the worker thread at game load, and many times in the UI thread
            -- note that the state can only be changed in the worker thread.
            if loadedState then
                -- logger.print('script.load firing, loadedState is') logger.debugPrint(loadedState)
                state = {}
                state.capacityFactor = loadedState.capacityFactor or _defaultCapacityFactor
                state.consumptionFactor = loadedState.consumptionFactor or _defaultConsumptionFactor
                state.personCapacityFactor = loadedState.personCapacityFactor or _defaultPersonCapacityFactor
            else
                -- logger.print('script.load firing, loadedState is NIL, api.gui is', not(api.gui) and 'NIL' or 'AVAILABLE')
                state = {
                    capacityFactor = _defaultCapacityFactor,
                    consumptionFactor = _defaultConsumptionFactor,
                    personCapacityFactor = _defaultPersonCapacityFactor,
                }
            end
            if not(api.gui) then -- this is the one call from the worker thread, when starting
                -- (there are actually two calls on start, not one, never mind)
                -- loadedState is the last saved state from the save file (eg lollo-test-01.sav.lua)
                -- use it to update the temporary file, which we need to convey data to building.updateFn() across lua states
                logger.print('script.load firing from the worker thread, state =') logger.debugPrint(state)
                commonData.set(state)
            end
        end,
        save = function()
            -- fired from the worker thread, at intervals
            -- logger.print('script.save firing, api.gui is', not(api.gui) and 'NIL' or 'AVAILABLE')
            if not state then state = {} end
            if not state.capacityFactor then state.capacityFactor = _defaultCapacityFactor end
            if not state.consumptionFactor then state.consumptionFactor = _defaultConsumptionFactor end
            if not state.personCapacityFactor then state.personCapacityFactor = _defaultPersonCapacityFactor end
            return state
        end,
        -- update = function()
        --     -- fires at intervals in the worker thread
        --     print('script.update')
        -- end,
    }
end
