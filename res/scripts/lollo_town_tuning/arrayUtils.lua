local arrayUtils = {}

arrayUtils.arrayHasValue = function(tab, val)
    for _, v in pairs(tab) do
        if v == val then
            return true
        end
    end

    return false
end
arrayUtils.addUnique = function(tab, val)
    if not arrayUtils.arrayHasValue(tab, val) then
        table.insert(tab, #tab + 1, val)
    end
end
arrayUtils.map = function(arr, func)
    if type(arr) ~= 'table' then return {} end
    
    local results = {}
    for i = 1, #arr do
        table.insert(results, #results + 1, func(arr[i]))
    end
    return results
end

arrayUtils.cloneDeepOmittingFields = function(tab, fields2Omit, isTryUserdata)
    local results = {}
    if type(tab) ~= 'table' and not(isTryUserdata and type(tab) == 'userdata') then return results end

    if type(fields2Omit) ~= 'table' then fields2Omit = {} end

    for key, value in pairs(tab) do
        if not arrayUtils.arrayHasValue(fields2Omit, key) then
            if type(value) == 'table' or (isTryUserdata and type(value) == 'userdata') then
                results[key] = arrayUtils.cloneDeepOmittingFields(value, fields2Omit, isTryUserdata)
            else
                results[key] = value
            end
        end
    end
    return results
end

arrayUtils.cloneOmittingFields = function(tab, fields2Omit, isTryUserdata)
    local results = {}
    if type(tab) ~= 'table' and not(isTryUserdata and type(tab) == 'userdata') then return results end

    if type(fields2Omit) ~= 'table' then fields2Omit = {} end

    for key, value in pairs(tab) do
        if not arrayUtils.arrayHasValue(fields2Omit, key) then
            results[key] = value
        end
    end
    return results
end

arrayUtils.concatValues = function(table1, table2)
    if type(table1) ~= 'table' or type(table2) ~= 'table' then
        return
    end

    for _, v2 in pairs(table2) do
        table.insert(table1, #table1 + 1, v2)
    end
end

arrayUtils.concatKeysValues = function(table1, table2)
    if type(table1) ~= 'table' or type(table2) ~= 'table' then
        return
    end

    for k2, v2 in pairs(table2) do
        table1[k2] = v2
    end
end

arrayUtils.getFirst = function(tab)
    if tab == nil or #tab == nil then return nil end

    return tab[1]
end

arrayUtils.getLast = function(tab)
    if tab == nil or #tab == nil then return nil end

    return tab[#tab]
end

arrayUtils.sort = function(table0, elementName, asc)
    if type(table0) ~= 'table' then
        return table0
    end

    if type(asc) ~= 'boolean' then
        asc = true
    end

    if type(elementName) == 'string' then
        table.sort(
            table0,
            function(elem1, elem2)
                if not elem1 or not elem2 or not (elem1[elementName]) or not (elem2[elementName]) then
                    return true
                end
                if asc then
                    return elem1[elementName] < elem2[elementName]
                end
                return elem1[elementName] > elem2[elementName]
            end
        )
    else
        table.sort(
            table0,
            function(elem1, elem2)
                if not elem1 or not elem2 or not (elem1) or not (elem2) then
                    return true
                end
                if asc then
                    return elem1 < elem2
                end
                return elem1 > elem2
            end
        )
    end

    return table0
end

arrayUtils.getCount = function(tab, isDiscardNil)
    if type(tab) ~= 'table' and type(tab) ~= 'userdata' then
        return -1
    end

    local result = 0
    for _, value in pairs(tab) do
        if not(isDiscardNil) or value ~= nil then
            result = result + 1
        end
    end

    return result
end

arrayUtils.findIndex = function(tab, fieldName, fieldValueNonNil)
    if type(tab) ~= 'table' or fieldValueNonNil == nil then return -1 end

    if type(fieldName) == 'string' then
        if string.len(fieldName) > 0 then
            for key, value in pairs(tab) do
                if type(value) == 'table' and value[fieldName] == fieldValueNonNil then
                    -- print('LOLLO findIndex found index =', i, 'tab[i][fieldName] =', tab[i][fieldName], 'fieldValueNonNil =', fieldValueNonNil, 'content =')
                    -- debugPrint(tab[i])
                    return key
                end
            end
        end
    else
        for key, value in pairs(tab) do
            if value == fieldValueNonNil then
                return key
            end
        end
    end

    return -1
end

arrayUtils.addProps = function(baseTab, addedTab)
    if type(baseTab) ~= 'table' or type(addedTab) ~= 'table' then return baseTab end

    for k, v in pairs(addedTab) do
        baseTab[k] = v
    end

    return baseTab
end

arrayUtils.getReversed = function(tab)
    if type(tab) ~= 'table' then return tab end

    local reversedTab = {}
    for i = #tab, 1, -1 do
        reversedTab[#reversedTab+1] = tab[i]
    end

    return reversedTab
end

return arrayUtils
