function get(self, k)
   if not self[k] then
      self[k] = {ids = {}, idEnds = {}, children = {}}
   end
   return self[k]
end

function add(self, path, id)
   local value = self
   for i, name in pairs(path) do
      value = get(value.children, name)
      value.ids[#value.ids + 1] = id
      if i == #path then
         value.idEnds[#value.idEnds + 1] = id
      end
   end
end

function deps(self, path)
   local value = self
   local result = {}
   for i, name in ipairs(path) do
      value = get(value.children, name)
      if i == #path then
         for _, id in ipairs(value.ids) do
            result[#result + 1] = id
         end
      else
         for _, id in ipairs(value.idEnds) do
            result[#result + 1] = id
         end
      end
   end

   return result
end

function emptyTrie()
   return {add = add, deps = deps, children = {}}
end

return {empty = emptyTrie}
