local trie = require 'pathData'

-- Helper function copied from the internet.
function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) == 'table' then k = dump(k) elseif
         type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

-- One of the coolest parts of Nixos modules is how the use laziness. Every
-- module has access to the finished config table despite the finished table
-- not existing yet. The Nix runtime finds a dependency tree of sorts between
-- the various modules and executes them in the correct order. As long as the
-- dependency tree doesn't have cycles, everything is fine.
--
-- Lua doesn't have laziness so we're going to create the dependency tree
-- explicitely in this function using a topological sort. Since we don't have
-- access to any cool abstractions like Applicative Functors, transformations
-- (modifications) need to explicitely list their inputs and outputs.
function runModTree(config)
    local allMods = Declua.allMods
    local paths = trie.empty()
    local tree = {}
    for i, mod in ipairs(allMods) do
        tree[i] = {}
        mod.id = i
        for _, output in ipairs(mod.outputs) do
            paths:add(output, i)
        end
    end


    for i, mod in ipairs(allMods) do
        for _, input in ipairs(mod.inputs) do
            for _, depOn in ipairs(paths:deps(input)) do
                tree[depOn][#tree[depOn] + 1] = i
            end
        end
    end

    local order = {}
    local marked = {}

    -- This part copied pretty much exactly from Wikidpedia.
    visit = function(n)
        if marked[n] == 1 then
            return
        elseif marked[n] == 0 then
            print("NOT A DAG")
            assert(nil)
        end
        marked[n] = 0
        for _, m in ipairs(tree[n]) do
            visit(m)
        end
        marked[n] = 1
        order[#order + 1] = n
    end

    for i, _ in ipairs(allMods) do
        if not marked[i] then
            visit(i)
        end
    end

    for i = #order, 1, -1 do
        allMods[order[i]].f(config)
    end
end

local mods = require 'mods'
local options = require 'dataTypes'

Declua = {
    allMods = {},
    allOptions = {},
    addMod = mods.addMod,
    addOption = options.addOption,
    runModTree = runModTree
}
