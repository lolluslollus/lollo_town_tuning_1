local stringUtils = {}
stringUtils.arrayHasValue = function(tab, val)
    for i, v in ipairs(tab) do
        if v == val then
            return true
        end
    end

    return false
end
stringUtils.isNullOrEmptyString = function(str)
    return str == nil or (type(str) == 'string' and string.len(str) == 0)
end
stringUtils.stringContainsOneOf = function(testString, tab)
    if stringUtils.isNullOrEmptyString(testString) then
        return false
    end
    if type(tab) ~= 'table' or #tab == 0 then
        return false
    end

    for i, v in ipairs(tab) do
        if stringUtils.stringContains(testString, v) then
            return true
        end
    end

    return false
end
stringUtils.stringSplit = function(testString, separatorString)
    local results = {}
    if testString == nil then
        return results
    end
    if separatorString == nil then
        separatorString = '%s'
    end

    -- for w in string.gmatch(testString, "([^" .. separatorString .. "]*)" .. separatorString) do
    for w in string.gmatch(testString, '([^' .. separatorString .. ']+)') do
        -- print(w)
        table.insert(results, w)
    end
    return results
    -- consume it so:
    -- for k, v in pairs(stringSplit(str0, "/")) do
    -- for k, v in ipairs(stringSplit(str0, "/")) do
    --     print(k, v)
    -- end
end
stringUtils.stringStartsWith = function(testString, startString)
    if not (startString) then
        return true
    end
    if not (testString) then
        return false
    end
    return string.sub(testString, 0, #startString) == startString
end
stringUtils.stringEndsWith = function(testString, endString)
    if not (endString) then
        return true
    end
    if not (testString) then
        return false
    end
    return string.sub(testString, -(#endString)) == endString
end
stringUtils.stringContains = function(testString, containedString)
    if type(testString) ~= 'string' or type(containedString) ~= 'string' then
        return false
    end
    return not (not (string.find(testString, containedString)))
end
stringUtils.getSteamTextWithNoTags = function(str)
    return string.gsub(str, '%[[%w+/+]+%]', '')
end

return stringUtils
