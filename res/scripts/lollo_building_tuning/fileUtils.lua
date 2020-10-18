local stringUtils = require('lollo_building_tuning.stringUtils')

local function _getPackageCpaths()
    -- returns something like
    -- {
    --     "C:\Program Files (x86)\Steam\steamapps\common\Transport Fever 2\?.dll",
    --     "C:\Program Files (x86)\Steam\steamapps\common\Transport Fever 2\loadall.dll",
    --     ".\?.dll"
    -- }
    -- or
    -- {
    --     "/usr/local/lib/lua/5.2/?.so",
    --     "/usr/local/lib/lua/5.2/loadall.so", 3 = "./?.so"
    -- }

    return stringUtils.stringSplit(string.gsub(package.cpath, '\\', '/'), ';')
end
local function _getPackagePaths()
    -- returns something like
    -- {
    --     "C:/Program Files (x86)/Steam/userdata/<steam user id>/1066780/local/staging_area/lollo_street_tuning_1/res/scripts/?.lua",
    --     "res/scripts/?.lua"
    -- }
    -- or
    -- {
    --     "/home/lollus/.local/share/Steam/userdata/71590188/1066780/local/staging_area/lollo_street_tuning_1/res/scripts/?.lua", 
    --     "/home/lollus/.local/share/Steam/userdata/71590188/1066780/local/staging_area/lollo_elevated_stations_1/res/scripts/?.lua",
    --     "res/scripts/?.lua"
    -- }

    return stringUtils.stringSplit(string.gsub(package.path, '\\', '/'), ';')
end

local function _getIsPosixSystem()
    return package.config:sub(1,1) == '/'
end

local function _getFilesInDir_Posix(dirPath, filterFn)
    filterFn = type(filterFn) == 'function' and filterFn or function(fileName)
        return true
    end

    local dirPathWithEndingSlash = stringUtils.stringEndsWith(dirPath, '/') and dirPath or (dirPath .. '/')
    local i, results, popen = 0, {}, io.popen
    local pfile = popen('ls -a "'..dirPathWithEndingSlash..'"')
    -- local pfile = popen('ls -l "'..dirPathWithEndingSlash..'"')
    local pfileLines = pfile:lines()
    for filePath in pfileLines do
        if string.len(filePath) > 0 and filterFn(filePath) then
            i = i + 1
            results[i] = dirPathWithEndingSlash .. filePath
        end
    end
    pfile:close()

    -- print('LOLLO files in dir = ')
    -- dump(true)(results)
    return results
end

local function _getFilesInDir_Windows(dirPath, filterFn)
    local dirPathWithEndingSlash = stringUtils.stringEndsWith(dirPath, '/') and dirPath or (dirPath .. '/')
    filterFn = type(filterFn) == 'function' and filterFn or function(fileName)
            return true
        end
    local result = {}
    local pfile = io.popen(string.format([[dir "%s" /b /a-d]], dirPathWithEndingSlash))
    --local pfile = io.popen(string.format([[dir "%s" /b /ad]], dirPathWithEndingSlash))
    if pfile then
        for filePath in pfile:lines() do
            if ((string.len(filePath) > 0) and filterFn(filePath)) then
                result[#result + 1] = string.format([[%s%s]], dirPathWithEndingSlash, filePath)
            --result[#result + 1] = string.format([[%s%s/]], dirPathWithEndingSlash, filePath)
            end
        end
        pfile:close()
    end

    return result
end

local function _getGamePath_Posix()
    local paths = _getPackagePaths()
    if type(paths) ~= 'table' or #paths < 1 then
        return ''
    end

    local path = ''
    local i = 1
    while stringUtils.isNullOrEmptyString(path) and i <= #paths do
        if stringUtils.stringContains(paths[i], '/Steam/userdata/') then
            path = paths[i]
        end
        i = i + 1
    end

    if stringUtils.isNullOrEmptyString(path) then
        return ''
    end

    local pos1 = string.find(path, '/Steam/userdata/')
    if pos1 == nil then return '' end

    local steamParentPath = string.sub(path, 1, pos1)
    if stringUtils.isNullOrEmptyString(steamParentPath) then return '' end

    return steamParentPath .. 'Steam/steamapps/common/\'Transport Fever 2\'/'
end

local function _getGamePath_Windows()
    local cpaths = _getPackageCpaths()
    if type(cpaths) ~= 'table' or #cpaths < 1 then
        return ''
    end

    local cpath = ''
    local i = 1
    while stringUtils.isNullOrEmptyString(cpath) and i <= #cpaths do
        if stringUtils.stringContains(cpaths[i], 'Transport Fever 2') then
            cpath = cpaths[i]
        end
        i = i + 1
    end

    if stringUtils.isNullOrEmptyString(cpath) then
        return ''
    end

    local reversedPath = string.reverse(cpath)
    local one, two = string.find(reversedPath, '/2 reveF tropsnarT/')
    if one == nil then
        return ''
    end

    return string.reverse(string.sub(reversedPath, one)) or ''
end


local fileUtils = {}
fileUtils.fileExists = function(filePath)
    local file = io.open(filePath, 'r')
    if file then
        file:close()
        return true
    end
    return false
end

fileUtils.readGameDataFile = function(filePath)
    local file = io.open(filePath, 'r')
    if file == nil then
        -- print('LOLLO file not found')
        return false
    end

    -- this works, but it returns a file that returns nothing, coz street files are structured this way
    -- local file, err = loadfile(<full path>)
    -- print('LOLLO err = ', err)
    -- print(inspect(file)) -- a function
    -- print(inspect(file())) -- nil. Note that street files do not return anything.

    -- file has type userdata
    -- print('LOLLO start reading the file')
    local fileContents = file:read('*a') -- this works! it reads the file contents! However, it adds a funny character at the beginning.
    -- print('LOLLO closing the file')
    file:close()

    if stringUtils.isNullOrEmptyString(fileContents) then return false end

    -- We need to remove the funny character at the beginning
    -- and the function name, or load() will fail. Consider the following:
    --    local ee = return function(a,b) return a+b end -- works
    --    local ee = return function data(a,b) return a+b end -- fails
    local searchStr = '[%W]*function[%s]+data[%s]*%('
    local howManyMatches = 0
    fileContents, howManyMatches = string.gsub(fileContents, searchStr, 'return function(', 1)

    -- print('LOLLO adjusted file contents = ')
    -- dump(true)(fileContents)
    -- print('LOLLO howManyMatches = ')
    -- dump(true)(howManyMatches)

    if howManyMatches == 0 then
        return false
    end

    --local myFileFunc = loadstring(fileContents) -- it fails coz loadstring is not available anymore
    -- local func, err = load('return function(a,b) return a+b end')
    -- if func then
    --     local ok, add = pcall(func)
    --     if ok then
    --         print('LOLLO test 4 load', add(2, 3))
    --     else
    --         print('Execution error:', add)
    --     end
    -- else
    --     print('Compilation error:', err)
    -- end

    local func, err = load(fileContents)
    if func then
        local ok, fc = pcall(func)
        if ok then
            -- print('LOLLO test 4 load -----------------------------------')
            -- dump(true)(fc()) -- fc now contains my street data!
            return true, fc()
        else
            print('lollo file utils - Execution error:', fc)
        end
    else
        print('lollo file utils - Compilation error:', err)
    end

    return false
end

fileUtils.getCurrentPath = function()
    local currPath = string.sub(debug.getinfo(1, 'S').source, 2)
    return string.gsub(currPath, '\\', '/')
    --    return string.sub(debug.getinfo(1, 'S').source, 2)

    -- returns something like
    -- "@<full path>"
    -- so we take out the first character, which is no control character by the way, so we cannot use gsub with %c

    -- local info
    -- local i = 1
    -- repeat
    --     info = debug.getinfo(i, 'S')
    --     i = i + 1
    -- until info == nil
    -- info = debug.getinfo(i - 2, 'S')

    -- return info

    -- it will find stuff like
    -- {
    --     lastlinedefined = 91,
    --     linedefined = 75,
    --     short_src = "...ing_area/lollo_street_tuning_1/res/scripts/fileUtils.lua",
    --     source = "@<full path>",
    --     what = "Lua"
    -- }
    -- and then
    -- {
    --     lastlinedefined = 75,
    --     linedefined = 9,
    --     short_src = "[string "C:/Program Files (x86)/Steam/userdata/7159018..."]",
    --     source = ".../res/construction/lollo_street_chunks.con",
    --     what = "Lua"
    -- }
    -- and then
    -- {
    --     lastlinedefined = 235,
    --     linedefined = 7,
    --     short_src = "[string "C:/Program Files (x86)/Steam/userdata/7159018..."]",
    --     source = ".../res/construction/lollo_street_chunks.con",
    --     what = "Lua"
    -- }
    -- and then
    -- {
    --     lastlinedefined = 235,
    --     linedefined = 7,
    --     short_src = "[string "C:/Program Files (x86)/Steam/userdata/7159018..."]",
    --     source = ".../res/construction/lollo_street_chunks.con",
    --     what = "Lua"
    -- }
end

fileUtils.getFileNameFromPath = function(path)
    if stringUtils.stringEndsWith(path, '/') then
        path = string.sub(path, 1, string.len(path) - 1)
    end

    local splits = stringUtils.stringSplit(path, '/')
    return splits[#splits] or ''
end

fileUtils.getParentDirFromPath = function(path)
    local searchString = '[^/]*/'
    return string.reverse(string.gsub(string.reverse(path), searchString, '', 1))
end

fileUtils.getResDirFromPath = function(path)
    local searchString = '.*/ser/'
    return string.reverse(string.gsub(string.reverse(path), searchString, 'ser/'))
end

fileUtils.getFilesInDir = function(dirPath, filterFn)
    if _getIsPosixSystem() then
        return _getFilesInDir_Posix(dirPath, filterFn)
    else
        return _getFilesInDir_Windows(dirPath, filterFn)
    end
end

fileUtils.getFilesInDirWithExtension = function(dirPath, ext)
    if ext == nil then
        return {}
    end

    local extWithoutDot = string.sub(ext, 1, 1) == '.' and string.sub(ext, 2, 1) or ext
    return fileUtils.getFilesInDir(
        dirPath,
        function(fileName)
            return stringUtils.stringEndsWith(fileName, '.' .. extWithoutDot)
        end
    )
end

fileUtils.getGamePath = function()
    if _getIsPosixSystem() then
        return _getGamePath_Posix()
    else
        return _getGamePath_Windows()
    end
end

local function _exportString(s)
    return string.format("%q", s)
end

-- from http://lua-users.org/wiki/SaveTableToFile
fileUtils.saveTable = function(tbl, filename)
    local charS, charE = "   ", "\n"
    local file, err = io.open(filename, "wb")
    if err then return err end

    -- initiate variables for save procedure
    local tables, lookup = { tbl }, { [tbl] = 1 }
    file:write( "return {"..charE )

    for idx, t in ipairs( tables ) do
        file:write( "-- Table: {"..idx.."}"..charE )
        file:write( "{"..charE )
        local thandled = {}

        for i, v in ipairs( t ) do
            thandled[i] = true
            local stype = type( v )
            -- only handle value
            if stype == "table" then
            if not lookup[v] then
                table.insert( tables, v )
                lookup[v] = #tables
            end
            file:write( charS.."{"..lookup[v].."},"..charE )
            elseif stype == "string" then
            file:write(  charS.._exportString( v )..","..charE )
            elseif stype == "number" then
            file:write(  charS..tostring( v )..","..charE )
            end
        end

        for i, v in pairs( t ) do
            -- escape handled values
            if (not thandled[i]) then

            local str = ""
            local stype = type( i )
            -- handle index
            if stype == "table" then
                if not lookup[i] then
                    table.insert( tables,i )
                    lookup[i] = #tables
                end
                str = charS.."[{"..lookup[i].."}]="
            elseif stype == "string" then
                str = charS.."[".._exportString( i ).."]="
            elseif stype == "number" then
                str = charS.."["..tostring( i ).."]="
            end

            if str ~= "" then
                stype = type( v )
                -- handle value
                if stype == "table" then
                    if not lookup[v] then
                        table.insert( tables,v )
                        lookup[v] = #tables
                    end
                    file:write( str.."{"..lookup[v].."},"..charE )
                elseif stype == "string" then
                    file:write( str.._exportString( v )..","..charE )
                elseif stype == "number" then
                    file:write( str..tostring( v )..","..charE )
                end
            end
            end
        end
        file:write( "},"..charE )
    end
    file:write( "}" )
    file:close()
end

fileUtils.loadTable = function(sfile)
    local ftables, err = loadfile(sfile)
    if err then return _, err end

    local tables = ftables()
    for idx = 1, #tables do
        local tolinki = {}
        for i, v in pairs( tables[idx] ) do
            if type( v ) == "table" then
            tables[idx][i] = tables[v[1]]
            end
            if type( i ) == "table" and tables[i[1]] then
            table.insert( tolinki, { i, tables[i[1]] } )
            end
        end
        -- link indices
        for _, v in ipairs( tolinki ) do
            tables[idx][v[2]], tables[idx][v[1]] =  tables[idx][v[1]], nil
        end
    end
    return tables[1]
end

return fileUtils
