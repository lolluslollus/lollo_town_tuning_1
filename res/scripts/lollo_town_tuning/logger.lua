local _constants = {
    isExtendedLog = false
}

local _util = {
    getIsExtendedLog = function()
        return _constants.isExtendedLog
    end,

    print = function(...)
        if not(_constants.isExtendedLog) then return end

        print(...)
    end,

    debugPrint = function(whatever)
        if not(_constants.isExtendedLog) then return end
        debugPrint(whatever)
    end
}

return _util
