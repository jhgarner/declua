function addOption(path, t)
   Declua.allOptions[table.concat(path, "/")] = t
end

-- A table which merges values in a shallow way
shallowTable = {}
function shallowTable.isValid(t)
   return type(t) == "table"
end

function shallowTable.merge(old, new)
   if old == nil then
      return new
   end
   for varName, varValue in pairs(new) do
      old[varName] = varValue
   end
   return old
end

-- An array which appends new values
array = {}
function array.isValid(t)
   -- TODO do something real here...
   return type(t) == "table"
end
function array.merge(old, new)
   if old == nil then
      return new
   end
   for _,v in ipairs(new) do 
      table.insert(old, v)
   end
   return old
end

bool = {}
function bool.isValid(t)
   return type(t) == "boolean"
end
function bool.merge(old, new)
   if old == nil then
      return new
   elseif old ~= new then
      error "Can't merge bool values!"
   else
      return old
   end
end

str = {}
function str.isValid(t)
   return type(t) == "str"
end
function str.merge(old, new)
   if old ~= new then
      error "Can't merge string values!"
   else
      return old
   end
end

unit = {}
function unit.isValid(t)
   return t == nil
end
function unit.merge(old, new)
   return {}
end

-- default = {}
-- function default(inner)
--    outer = {}
--    outer.isValid = function(v)
--       return v == nil or inner.isValid(v)
--    end
--    outer.merge = function(old, new)

--    end
-- end
-- function default.isValid(v)
--    return t.value == nil or t.value.isValid(t)
-- end

return {shallowTable = shallowTable, array = array, addOption = addOption}
