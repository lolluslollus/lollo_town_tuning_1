local arrayUtils = {}

arrayUtils.arrayHasValue = function(tab, val)
    for i, v in ipairs(tab) do
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

arrayUtils.cloneDeepOmittingFields = function(tab, fields2Omit)
    local results = {}
    if type(tab) ~= 'table' then return results end

    if type(fields2Omit) ~= 'table' then fields2Omit = {} end

    for key, value in pairs(tab) do
        if not arrayUtils.arrayHasValue(fields2Omit, key) then
            if type(value) == 'table' then
                results[key] = arrayUtils.cloneDeepOmittingFields(value, fields2Omit)
            else
                results[key] = value
            end
        end
    end
    return results
end

arrayUtils.cloneOmittingFields = function(tab, fields2Omit)
    local results = {}
    if type(tab) ~= 'table' then return results end

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

arrayUtils.sort = function(table0, elementName, asc)
    if type(table0) ~= 'table' or type(elementName) ~= 'string' then
        return table0
    end

    if type(asc) ~= 'boolean' then
        asc = true
    end

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

    return table0
end

arrayUtils.findIndex = function(tab, fieldName, fieldValueNonNil)
    if type(tab) ~= 'table' or type(fieldName) ~= 'string' or string.len(fieldName) < 1 or fieldValueNonNil == nil then return -1 end

    for i = 1, #tab do
        if type(tab[i]) == 'table' and tab[i][fieldName] == fieldValueNonNil then
            -- print('LOLLO findIndex found index =', i, 'tab[i][fieldName] =', tab[i][fieldName], 'fieldValueNonNil =', fieldValueNonNil, 'content =')
            -- debugPrint(tab[i])
            return i
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

return arrayUtils
