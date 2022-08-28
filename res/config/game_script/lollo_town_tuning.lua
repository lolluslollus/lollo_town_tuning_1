local arrayUtils = require('lollo_town_tuning.arrayUtils')
local commonData = require('lollo_town_tuning.commonData')
local logger = require('lollo_town_tuning.logger')

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
    updateState = 'updateState',
}

-- these 3 text fields are global so they can only update once the API has been loaded
local _guiResOutput = nil -- api.gui.comp.TextView.new('')
local _guiComOutput = nil -- api.gui.comp.TextView.new('')
local _guiIndOutput = nil -- api.gui.comp.TextView.new('')

local _townInitialLandUseCapacities = {
    bigStep = 500,
    max = 5000,
    min = 0,
    step = 50,
}

local _tuningTabId = 'lolloTownTuningTab'


local _utils = {
    isValidId = function(id)
        return type(id) == 'number' and id > 0
    end,
}
_utils.isValidAndExistingId = function(id)
    return _utils.isValidId(id) and api.engine.entityExists(id)
end
_utils.getCargoNeeds = function(townId)
    if not(_utils.isValidAndExistingId(townId)) then return nil end

    local townData = api.engine.getComponent(townId, api.type.ComponentType.TOWN)
    if not(townData) then return nil end
    local cargoSupplyAndLimit = api.engine.system.townBuildingSystem.getCargoSupplyAndLimit(townId)
    if not(cargoSupplyAndLimit) then return nil end

    -- LOLLO NOTE since build 35045, townData.cargoNeeds contains 3 com and 3 ind,
    -- even if they are not in use.
    -- As a consequence, we cannot simply return townData.cargoNeeds anymore.
    -- To fix this, we match cargo needs to cargo in use.
    --[[
        cargoSupplyAndLimit = {
            [11] = 0,
            [14] = 0,
        }
    ]]
    local usedCargoIdsIndexed = {}
    for cargoTypeId, cargoSupply in pairs(cargoSupplyAndLimit) do
        logger.print(cargoTypeId, cargoSupply)
        usedCargoIdsIndexed[cargoTypeId] = true
    end

    --[[
        cargoNeeds = {
            [1] = {
            },
            [2] = {
                [1] = 14,
                [2] = 15,
                [3] = 16,
            },
            [3] = {
                [1] = 11,
                [2] = 12,
                [3] = 13,
            },
        },
    ]]
    local cargoNeeds = {
        {},
        {},
        {},
    }
    for resComInd, needs in pairs(townData.cargoNeeds) do
        -- resComInd is 1 for res, 2 for com, 3 for ind
        for _, need in pairs(needs) do
            if usedCargoIdsIndexed[need] then
                table.insert(cargoNeeds[resComInd], need)
            end
        end
    end

    logger.print('townId =', townId, 'has cargoNeeds =') logger.debugPrint(cargoNeeds)
    return cargoNeeds
end

_utils.getAllCargoTypesButPassengers = function()
    local cargoNames = api.res.cargoTypeRep.getAll()
    if not(cargoNames) then return {} end

    local results = {}
    for k, v in pairs(cargoNames) do
        if v ~= 'PASSENGERS' then -- note that passengers has id = 0
            results[k] = api.res.cargoTypeRep.get(k)
        end
    end

    return results
end

_utils.getTowns = function()
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
end

local _triggers = {
    guiTriggerUpdateTown = function(townId, callback)
        logger.print('guiTriggerUpdateTown starting; townId =', townId or 'NIL')

        if not(_utils.isValidAndExistingId(townId)) then callback() return end

        local townCargoNeeds = _utils.getCargoNeeds(townId)
        if townCargoNeeds == nil then callback() return end

        logger.print('guiTriggerUpdateTown got townCargoNeeds =') logger.debugPrint(townCargoNeeds)

        -- logger.print('time 1 =', os.time())
        api.cmd.sendCommand(
            -- this triggers updateFn for all the town buildings
            api.cmd.make.instantlyUpdateTownCargoNeeds(townId, townCargoNeeds),
            function(result, success)
                logger.print('guiTriggerUpdateTown - instantlyUpdateTownCargoNeeds ended, success =', success, 'result =') logger.debugPrint(result)
                -- result looks like
                -- {
                --     townEntity = 19279,
                --     cargoNeeds = {
                --       [1] = {
                --       },
                --       [2] = {
                --         [1] = 16,
                --       },
                --       [3] = {
                --         [1] = 13,
                --         [2] = 8,
                --       },
                --     },
                --   }
                -- logger.print('time 2 =', os.time()) -- this can be 10 units higher than time 1, after updating a large town
                callback()
            end
        )
    end,

    guiTriggerUpdateTownCargoNeeds = function(townId, resComInd, cargoTypeId, isAdd, callback)
        logger.print('guiTriggerUpdateTownCargoNeeds starting; townId, resComInd, cargoTypeId, isAdd =', townId, resComInd, cargoTypeId, isAdd)

        if not(_utils.isValidAndExistingId(townId)) or not(_utils.isValidAndExistingId(cargoTypeId)) then callback() return end
        if not(arrayUtils.arrayHasValue({1, 2, 3}, resComInd)) then callback() return end

        local townCargoNeeds = _utils.getCargoNeeds(townId)
        if townCargoNeeds == nil then callback() return end

        logger.print('guiTriggerUpdateTownCargoNeeds got townCargoNeeds =') logger.debugPrint(townCargoNeeds)

        if isAdd then -- add
            if arrayUtils.arrayHasValue(townCargoNeeds[resComInd], cargoTypeId) then
                logger.print('cargoTypeId', cargoTypeId, 'is already available, leaving')
                callback()
                return
            else
                table.insert(townCargoNeeds[resComInd], cargoTypeId)
            end
        else -- remove
            local index = arrayUtils.findIndex(townCargoNeeds[resComInd], nil, cargoTypeId)
            if index < 0 then
                logger.print('cargoTypeId', cargoTypeId, 'wants to be removed but it is not available, leaving')
                callback()
                return
            else
                logger.print('townCargoNeeds[resComInd] before deletion =') logger.debugPrint(townCargoNeeds[resComInd])
                townCargoNeeds[resComInd][index] = nil
                logger.print('townCargoNeeds[resComInd] after deletion =') logger.debugPrint(townCargoNeeds[resComInd])
                -- remove holes in the output list keys: 1, 2, 3 instead of 1, 3, 4. Reverse engineering says no sorting.
                local newCargoNeeds4Area = {}
                for _, value in pairs(townCargoNeeds[resComInd]) do
                    if value ~= nil then
                        newCargoNeeds4Area[#newCargoNeeds4Area+1] = value
                    end
                end
                townCargoNeeds[resComInd] = newCargoNeeds4Area
                logger.print('newCargoNeeds4Area =') logger.debugPrint(newCargoNeeds4Area)
            end
        end

        logger.print('guiTriggerUpdateTownCargoNeeds about to send command with townCargoNeeds =') logger.debugPrint(townCargoNeeds)
        -- logger.print('time 1 =', os.time())
        api.cmd.sendCommand(
            -- this triggers updateFn for all the town buildings
            api.cmd.make.instantlyUpdateTownCargoNeeds(townId, townCargoNeeds),
            function(result, success)
                logger.print('guiTriggerUpdateTownCargoNeeds - instantlyUpdateTownCargoNeeds ended, success =', success, 'result =') logger.debugPrint(result)
                -- result looks like
                -- {
                --     townEntity = 19279,
                --     cargoNeeds = {
                --       [1] = {
                --       },
                --       [2] = {
                --         [1] = 16,
                --       },
                --       [3] = {
                --         [1] = 13,
                --         [2] = 8,
                --       },
                --     },
                --   }
                -- logger.print('time 2 =', os.time()) -- this can be 10 units higher than time 1, after updating a large town
                callback()
            end
        )
    end,

    guiTriggerUpdateTownInitialLandUse = function(townId, newCapa, resComInd)
        if not(_utils.isValidAndExistingId(townId)) then return end
        if not(arrayUtils.arrayHasValue({1, 2, 3}, resComInd)) then return end

        local townData = api.engine.getComponent(townId, api.type.ComponentType.TOWN)
        if townData == nil then return end

        local resCapa = resComInd == 1 and newCapa or townData.initialLandUseCapacities[1]
        local comCapa = resComInd == 2 and newCapa or townData.initialLandUseCapacities[2]
        local indCapa = resComInd == 3 and newCapa or townData.initialLandUseCapacities[3]

        api.cmd.sendCommand(
            -- this won't trigger updateFn for all the town buildings
            api.cmd.make.setTownInfo(townId, {resCapa, comCapa, indCapa}),
            function(result, success)
                logger.print('setTownInfo ended, success =', success)
                logger.debugPrint(result)
                if success and result and result.initialLandUseCapacities then
                    _guiResOutput:setText(tostring(result.initialLandUseCapacities[1]))
                    _guiComOutput:setText(tostring(result.initialLandUseCapacities[2]))
                    _guiIndOutput:setText(tostring(result.initialLandUseCapacities[3]))
                end
            end
        )
    end
}

_triggers.guiTriggerUpdateAllTowns = function(newState)
    logger.print('guiTriggerUpdateAllTowns starting, newState =') logger.debugPrint(newState)
    if newState == nil then return end

    local _setResult = commonData.set(arrayUtils.cloneDeepOmittingFields(newState)) -- do this now, the other thread might take too long
    logger.print('guiTriggerUpdateAllTowns - setResult =') logger.debugPrint(_setResult)

    local _tuningTab = api.gui.util.getById(_tuningTabId)
    _tuningTab:setEnabled(false)

    local allTownsCount = 0
    local processedTownsCount = 0
    local _towns = _utils.getTowns()
    for _, _ in pairs(_towns) do
        allTownsCount = allTownsCount + 1
    end

    local _endHandler = function()
        processedTownsCount = processedTownsCount + 1
        if processedTownsCount >= allTownsCount then
            logger.print('all towns updated')
            api.cmd.sendCommand(
                api.cmd.make.sendScriptEvent(
                    string.sub(debug.getinfo(1, 'S').source, 1),
                    _eventId,
                    _eventNames.updateState,
                    arrayUtils.cloneDeepOmittingFields(newState)
                ),
                function(result, success)
                    -- set the state after processing the new town props,
                    -- since it is then saved with the game,
                    -- and then release the UI. 
                    logger.print('guiTriggerUpdateAllTowns - updateState success =', success, 'result =') logger.debugPrint(result)
                    _tuningTab:setEnabled(true)
                end
            )
        end
    end
    for townId, _ in pairs(_towns) do
        _triggers.guiTriggerUpdateTown(townId, _endHandler)
    end
end

local state = nil
local _dataHelpers = {
    getState = function()
        local result = arrayUtils.cloneDeepOmittingFields(state)
        if type(result) ~= 'table' then
            logger.print('getState found no state, returning defaults')
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
        if type(index) ~= 'number' then return end

        local newState = arrayUtils.cloneDeepOmittingFields(state)
        if type(newState.capacityFactor) ~= 'number' then
            newState.capacityFactor = _defaultCapacityFactor
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

        if newFactor == newState.capacityFactor then return end

        newState.capacityFactor = newFactor
        _triggers.guiTriggerUpdateAllTowns(arrayUtils.cloneDeepOmittingFields(newState))
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
        if type(index) ~= 'number' then return end

        local newState = arrayUtils.cloneDeepOmittingFields(state)
        if type(newState.consumptionFactor) ~= 'number' then
            newState.consumptionFactor = _defaultConsumptionFactor
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

        if newFactor == newState.consumptionFactor then return end

        newState.consumptionFactor = newFactor
        _triggers.guiTriggerUpdateAllTowns(arrayUtils.cloneDeepOmittingFields(newState))
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
        if type(index) ~= 'number' then return end

        local newState = arrayUtils.cloneDeepOmittingFields(state)
        if type(newState.personCapacityFactor) ~= 'number' then
            newState.personCapacityFactor = _defaultPersonCapacityFactor
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

        if newFactor == newState.personCapacityFactor then return end

        newState.personCapacityFactor = newFactor
        _triggers.guiTriggerUpdateAllTowns(arrayUtils.cloneDeepOmittingFields(newState))
    end,
}

local _guiHelpers = {
    guiAddOneTownProps = function(parentLayout, townId)
        if type(townId) ~= 'number' or townId < 1 then return end
        logger.print('townId =', townId or 'NIL')

        local townData = api.engine.getComponent(townId, api.type.ComponentType.TOWN)
        logger.print('townData =') logger.debugPrint(townData or 'NIL')
        if not(townData) then return end

        local townCargoNeeds = _utils.getCargoNeeds(townId)

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
                    _triggers.guiTriggerUpdateTownInitialLandUse(townId, newValue, 1)
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
                    _triggers.guiTriggerUpdateTownInitialLandUse(townId, newValue, 2)
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
                    _triggers.guiTriggerUpdateTownInitialLandUse(townId, newValue, 3)
                end
            )

            return townInitialLandUseCapacitiesList
        end
        parentLayout:addItem(_addInitialLandUseCapacities())

        local _addCargoNeeds = function()
            local cargoTypesBox = api.gui.comp.Component.new('cargoTypesBox')
            cargoTypesBox:setLayout(api.gui.layout.BoxLayout.new('VERTICAL'))
            cargoTypesBox:getLayout():addItem(api.gui.comp.TextView.new(_('CARGO_NEEDS')))

            local cargoTypes = _utils.getAllCargoTypesButPassengers()
            -- logger.print('cargoTypes =') logger.debugPrint(cargoTypes or 'NIL')

            local cargoTypesGuiTable = api.gui.comp.Table.new(#cargoTypes + 1, 'NONE')
            cargoTypesGuiTable:setNumCols(3)
            cargoTypesGuiTable:addRow({
                api.gui.comp.TextView.new(_areaTypes.res.text),
                api.gui.comp.TextView.new(_areaTypes.com.text),
                api.gui.comp.TextView.new(_areaTypes.ind.text)
            })
            if townCargoNeeds ~= nil then
                local _tuningTab = api.gui.util.getById(_tuningTabId)
                for cargoTypeId, cargoData in pairs(cargoTypes) do
                    local resComp = api.gui.comp.Component.new(_areaTypes.res.id)
                    resComp:setLayout(api.gui.layout.BoxLayout.new('HORIZONTAL'))
                    resComp:getLayout():addItem(api.gui.comp.ImageView.new(cargoData.icon)) -- iconSmall
                    local resCheckBox = api.gui.comp.CheckBox.new('', 'ui/checkbox0.tga', 'ui/checkbox1.tga')
                    resCheckBox:onToggle(
                        function(newValue)
                            _tuningTab:setEnabled(false)
                            _triggers.guiTriggerUpdateTownCargoNeeds(townId, _areaTypes.res.index, cargoTypeId, newValue, function() _tuningTab:setEnabled(true) end)
                        end
                    )
                    for _, v in pairs(townCargoNeeds[1]) do
                        if v == cargoTypeId then resCheckBox:setSelected(true, false) end
                    end
                    resComp:getLayout():addItem(resCheckBox)

                    local comComp = api.gui.comp.Component.new(_areaTypes.com.id)
                    comComp:setLayout(api.gui.layout.BoxLayout.new('HORIZONTAL'))
                    comComp:getLayout():addItem(api.gui.comp.ImageView.new(cargoData.icon))
                    local comCheckBox = api.gui.comp.CheckBox.new('', 'ui/checkbox0.tga', 'ui/checkbox1.tga')
                    comCheckBox:onToggle(
                        function(newValue)
                            _tuningTab:setEnabled(false)
                            _triggers.guiTriggerUpdateTownCargoNeeds(townId, _areaTypes.com.index, cargoTypeId, newValue, function() _tuningTab:setEnabled(true) end)
                        end
                    )
                    for _, v in pairs(townCargoNeeds[2]) do
                        if v == cargoTypeId then comCheckBox:setSelected(true, false) end
                    end
                    comComp:getLayout():addItem(comCheckBox)

                    local indComp = api.gui.comp.Component.new(_areaTypes.ind.id)
                    indComp:setLayout(api.gui.layout.BoxLayout.new('HORIZONTAL'))
                    indComp:getLayout():addItem(api.gui.comp.ImageView.new(cargoData.icon))
                    local indCheckBox = api.gui.comp.CheckBox.new('', 'ui/checkbox0.tga', 'ui/checkbox1.tga')
                    indCheckBox:onToggle(
                        function(newValue)
                            _tuningTab:setEnabled(false)
                            _triggers.guiTriggerUpdateTownCargoNeeds(townId, _areaTypes.ind.index, cargoTypeId, newValue, function() _tuningTab:setEnabled(true) end)
                        end
                    )
                    for _, v in pairs(townCargoNeeds[3]) do
                        if v == cargoTypeId then indCheckBox:setSelected(true, false) end
                    end
                    indComp:getLayout():addItem(indCheckBox)

                    cargoTypesGuiTable:addRow({resComp, comComp, indComp})
                end
            end

            cargoTypesBox:getLayout():addItem(cargoTypesGuiTable)
            return cargoTypesBox
        end
        parentLayout:addItem(_addCargoNeeds())

    end,

    guiAddAllTownProps = function(parentLayout)
        local sharedData = _dataHelpers.getState()

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
                _dataHelpers.setCapacityFactor(newIndexBase0 + 1)
            end
        )
        for i = 1, #capacityToggleButtons do
            capacityToggleButtonGroup:add(capacityToggleButtons[i])
        end
        capacityToggleButtons[_dataHelpers.getCapacityFactorIndex(sharedData.capacityFactor)]:setSelected(true, false)

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
                _dataHelpers.setConsumptionFactor(newIndexBase0 + 1)
            end
        )
        for i = 1, #consumptionToggleButtons do
            consumptionToggleButtonGroup:add(consumptionToggleButtons[i])
        end
        consumptionToggleButtons[_dataHelpers.getConsumptionFactorIndex(sharedData.consumptionFactor)]:setSelected(true, false)

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
                _dataHelpers.setPersonCapacityFactor(newIndexBase0 + 1)
            end
        )
        for i = 1, #personCapacityToggleButtons do
            personCapacityToggleButtonGroup:add(personCapacityToggleButtons[i])
        end
        personCapacityToggleButtons[_dataHelpers.getPersonCapacityFactorIndex(sharedData.personCapacityFactor)]:setSelected(true, false)

        parentLayout:addItem(capacityTextViewTitle)
        parentLayout:addItem(capacityToggleButtonGroup)
        parentLayout:addItem(consumptionTextViewTitle)
        parentLayout:addItem(consumptionToggleButtonGroup)
        parentLayout:addItem(personCapacityTextViewTitle)
        parentLayout:addItem(personCapacityToggleButtonGroup)
    end,
}

_guiHelpers.guiAddTuningMenu = function(windowId, townId)
    -- these 3 must be inited in the UI thread
    _guiResOutput = api.gui.comp.TextView.new('')
    _guiComOutput = api.gui.comp.TextView.new('')
    _guiIndOutput = api.gui.comp.TextView.new('')

    logger.print('windowId =', windowId or 'NIL')
    local window = api.gui.util.getById(windowId)
    window:setResizable(true)

    local minSize = api.gui.util.Size.new() minSize.h = 1000 minSize.w = 800
    window:setSize(minSize)
    -- require("mobdebug").start()
    local windowContent = window:getContent()
    -- remove the "editor" tab if in sandbox mode
    if windowContent:getNumTabs() > 4 then
        local editorTab = windowContent:getTab(4)
        editorTab:setVisible(false, false) -- does not work
        editorTab:setEnabled(false) -- at least this works
    end

    local tuningTab = api.gui.comp.Component.new('TUNING')
    tuningTab:setId(_tuningTabId)
    tuningTab:setLayout(api.gui.layout.BoxLayout.new('VERTICAL'))
    windowContent:insertTab(
        api.gui.comp.TextView.new(_('TUNING_TAB_LABEL')),
        tuningTab,
        4
    )
    local tuningLayout = tuningTab:getLayout()
    _guiHelpers.guiAddAllTownProps(tuningLayout)
    _guiHelpers.guiAddOneTownProps(tuningLayout, townId)

    -- local minimumSize = window:calcMinimumSize()
    -- local newSize = api.gui.util.Size.new()
    -- newSize.h = minimumSize.h + 250
    -- newSize.w = minimumSize.w + 500
    -- -- window:setMinimumSize(newSize) -- useless
    -- window:setSize(newSize) -- flickers if h is too small
    -- window:setMaximiseSize(newSize.w, newSize.h, 1) -- flickers if h is too small, could be useful tho
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
            if name ~= 'idAdded' or type(id) ~= 'string' or not(id:find('temp.view.entity_')) then return end

            xpcall(
                function()
                    for townId, townData in pairs(_utils.getTowns()) do
                        if townData.townStatWindowId == id then
                            _guiHelpers.guiAddTuningMenu(id, townId)
                            break
                        end
                    end
                end,
                logger.xpErrorHandler
            )
        end,
        -- guiInit = function()
        -- fires once on start, it seems to fire after the worker thread fired save()
        --     logger.print('guiInit firing')
        -- end,
        -- guiUpdate = function()
        -- fires at intervals in the gui thread
        -- end,
        handleEvent = function(src, id, name, args)
            if id ~= _eventId then return end

            logger.print('handleEvent caught event with id =', id, 'src =', src, 'name =', name)

            if name == _eventNames.updateState then -- user pressed one of the "all towns" buttons
                logger.print('args =') logger.debugPrint(args)
                if args ~= nil then
                    state = arrayUtils.cloneDeepOmittingFields(args) -- LOLLO NOTE you can only update the state from the worker thread
                    logger.print('state updated, new state =') logger.debugPrint(state)
                end
            end
        end,
        load = function(loadedState)
            -- fires once in the worker thread at game load, and many times in the UI thread
            -- note that the state can only be changed in the worker thread.
            if loadedState then
                -- logger.print('script.load firing, loadedState is') logger.debugPrint(loadedState)
                state = {
                    capacityFactor = loadedState.capacityFactor or _defaultCapacityFactor,
                    consumptionFactor = loadedState.consumptionFactor or _defaultConsumptionFactor,
                    personCapacityFactor = loadedState.personCapacityFactor or _defaultPersonCapacityFactor,
                }
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
                local _setResult = commonData.set(state)
                logger.print('setResult =') logger.debugPrint(_setResult)
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
        --     logger.print('script.update')
        -- end,
    }
end
