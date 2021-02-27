local _constants = {
    isExtendedLog = true
}

local _util = {
    getIsExtendedLog = function()
        return _constants.isExtendedLog
    end,

    print = function(whatever1, whatever2, whatever3, whatever4, whatever5, whatever6, whatever7, whatever8, whatever9, whatever10)
        if not(_constants.isExtendedLog) then return end

        -- rubbish, does not work
        -- if type(arg) ~= 'table' then return end

        -- local printResult = ''
        -- for i, v in ipairs(arg) do
        --     print(i)
        --     print(v)
        -- -- for _, v in pairs(arg) do
        --     -- print(v) -- arg here is like arguments in JS
        --     printResult = printResult .. tostring(v) .. "\t" -- arg here is like arguments in JS
        -- end
        -- printResult = printResult .. "\n"

        print(whatever1 or '', whatever2 or '', whatever3 or '', whatever4 or '', whatever5 or '', whatever6 or '', whatever7 or '', whatever8 or '', whatever9 or '', whatever10 or '')
    end,

    debugPrint = function(whatever)
        if not(_constants.isExtendedLog) then return end
        debugPrint(whatever)
    end
}

return _util
