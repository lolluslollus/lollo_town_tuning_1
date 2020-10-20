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
local _eventId = '__lolloTownTuningEvent__'
local _eventNames = {
    changeCapacityFactor = 'changeCapacityFactor',
    changeConsumptionFactor = 'changeConsumptionFactor',
    changePersonCapacityFactor = 'changePersonCapacityFactor',
    changeCargoNeeds = 'changeCargoNeeds',
}
local _utils = {}
_utils.guiHandleCheckBoxToggle = function(townId, areaTypeId, cargoTypeId, newValue)
    print('townId =')
    debugPrint(townId)
    print('areaTypeId =')
    debugPrint(areaTypeId)
    print('cargoTypeId =')
    debugPrint(cargoTypeId)
    print('newValue =')
    debugPrint(newValue)
end
_utils.guiAddOneTownProps = function(parentLayout, townId)
    if type(townId) ~= 'number' or townId < 1 then return end

    local townData = api.engine.getComponent(townId, api.type.ComponentType.TOWN)
    if not(townData) then return end

    local cargoTypes = commonData.cargoTypes.getAll()
    local cargoTypesGuiTable = api.gui.comp.Table.new(#cargoTypes + 1, 'NONE')
    cargoTypesGuiTable:setNumCols(3)
    cargoTypesGuiTable:addRow({
        api.gui.comp.TextView.new(_areaTypes.res.text),
        api.gui.comp.TextView.new(_areaTypes.com.text),
        api.gui.comp.TextView.new(_areaTypes.ind.text)
    })
    for cargoTypeId, cargoData in pairs(cargoTypes) do
        -- print('cargo id =', cargoId)
        -- debugPrint(cargoData)
        local resComp = api.gui.comp.Component.new(_areaTypes.res.id)
        resComp:setLayout(api.gui.layout.BoxLayout.new('HORIZONTAL'))
        resComp:getLayout():addItem(api.gui.comp.ImageView.new(cargoData.icon)) -- iconSmall
        local resCheckBox = api.gui.comp.CheckBox.new('', 'ui/checkbox0.tga', 'ui/checkbox1.tga')
        resCheckBox:setId('lolloTownTuning_town_' .. tostring(townId) .. '_resCargoType_' .. tostring(cargoTypeId))
        resCheckBox:onToggle(
            function(newValue)
                _utils.guiHandleCheckBoxToggle(townId, _areaTypes.res.id, cargoTypeId, newValue)
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
        comCheckBox:setId('lolloTownTuning_town_' .. tostring(townId) .. '_comCargoType_' .. tostring(cargoTypeId))
        comCheckBox:onToggle(
            function(newValue)
                _utils.guiHandleCheckBoxToggle(townId, _areaTypes.com.id, cargoTypeId, newValue)
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
        indCheckBox:setId('lolloTownTuning_town_' .. tostring(townId) .. '_indCargoType_' .. tostring(cargoTypeId))
        indCheckBox:onToggle(
            function(newValue)
                _utils.guiHandleCheckBoxToggle(townId, _areaTypes.ind.id, cargoTypeId, newValue)
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
_utils.guiAddAllTownProps = function(parentLayout, townId)
    local sharedData = commonData.shared.get()

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
            commonData.shared.setCapacityFactor(newIndexBase0 + 1)
            for townId_, _ in pairs(commonData.towns.get()) do
                _utils.triggerUpdate4Town(townId_)
            end
            capacityToggleButtonGroup:setEnabled(true)
        end
    )
    for i = 1, #capacityToggleButtons do
        capacityToggleButtonGroup:add(capacityToggleButtons[i])
    end
    capacityToggleButtons[commonData.shared.getCapacityFactorIndex(sharedData.capacityFactor)]:setSelected(true, false)

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
            commonData.shared.setConsumptionFactor(newIndexBase0 + 1)
            for townId_, _ in pairs(commonData.towns.get()) do
                _utils.triggerUpdate4Town(townId_)
            end
            consumptionToggleButtonGroup:setEnabled(true)
        end
    )
    for i = 1, #consumptionToggleButtons do
        consumptionToggleButtonGroup:add(consumptionToggleButtons[i])
    end
    consumptionToggleButtons[commonData.shared.getConsumptionFactorIndex(sharedData.consumptionFactor)]:setSelected(true, false)

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
            commonData.shared.setPersonCapacityFactor(newIndexBase0 + 1)
            for townId_, _ in pairs(commonData.towns.get()) do
                _utils.triggerUpdate4Town(townId_)
            end
            personCapacityToggleButtonGroup:setEnabled(true)
        end
    )
    for i = 1, #personCapacityToggleButtons do
        personCapacityToggleButtonGroup:add(personCapacityToggleButtons[i])
    end
    personCapacityToggleButtons[commonData.shared.getPersonCapacityFactorIndex(sharedData.personCapacityFactor)]:setSelected(true, false)

    parentLayout:addItem(capacityTextViewTitle)
    parentLayout:addItem(capacityToggleButtonGroup)
    parentLayout:addItem(consumptionTextViewTitle)
    parentLayout:addItem(consumptionToggleButtonGroup)
    parentLayout:addItem(personCapacityTextViewTitle)
    parentLayout:addItem(personCapacityToggleButtonGroup)
end
_utils.guiAddTuningMenu = function(windowId, townId)
    -- print('town stats window opened, id, name, param, api.gui.util.getById ==')
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
    _utils.guiAddAllTownProps(tuningLayout, townId)
    _utils.guiAddOneTownProps(tuningLayout, townId)

    local minimumSize = window:calcMinimumSize()
    local newSize = api.gui.util.Size.new()
    newSize.h = minimumSize.h + 250
    newSize.w = minimumSize.w + 100
    -- window:setMinimumSize(newSize) -- useless
    window:setSize(newSize) -- flickers if h is too small
    -- window:setMaximiseSize(newSize.w, newSize.h, 1) -- flickers if h is too small
end
_utils.replaceBuildingWithSelf = function(oldBuildingId)
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
end
_utils.triggerUpdate4Town = function(townId)
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
end

local _actions = {
    alterCapacityFactorByTown = function(townId, isCapacityFactorUp)
        -- no good, call in a loop and you are in for a multithreading disaster
        print('alterCapacityFactorByTown starting, townId =', townId or 'NIL', 'isCapacityFactorUp =', isCapacityFactorUp or false)
        if type(townId) ~= 'number' or townId < 1 then return end

        commonData.shared.setCapacityFactor(isCapacityFactorUp)

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
    alterTownRequirements = function(townId, consumptionFactorDelta)
        -- LOLLO TODO implement this and its UI
        print('alterTownRequirements starting, townId =', townId, 'consumptionFactorDelta =', consumptionFactorDelta)
        _utils.triggerUpdate4Town(townId)
    end,
}

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
                            for townId, townData in pairs(commonData.towns.get()) do
                                if townData.townStatWindowId == id then
                                    _utils.guiAddTuningMenu(id, townId)
                                    break
                                end
                            end
                        end
                    end,
                    _myErrorHandler
            )
            end
        end,
    }
end

