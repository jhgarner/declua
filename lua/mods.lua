-- Used by addMod to check that a value matches some type t.
-- The metatable stuff is supposed to help when you have some kind of wrapper
-- which modifies some type. Those don't exist but they might in the future.
function typeCheck(t, value)
    local mt = getmetatable(value)
    if mt and mt.__wrapper then
        value = mt.__typeCheck(t)
    end
    return t.isValid(value)
end

-- Tries to combine valueA and valueB. TODO is this idiomatic Lua code?
function mergeType(t, valueA, valueB)
    local mta = getmetatable(valueA) or {__priority = 0, __wrapper = valueA}
    local mtb = getmetatable(valueB) or {__priority = 0, __wrapper = valueB}
    if mta.__priority == mtb.__priority then
        return t.merge(mta.__wrapper, mtb.__wrapper)
    elseif mta.__priority > mtb.__priority then
        return mta
    else
        return mtb
    end
end

-- Adds a modification (transformation) over parts of the config.
-- f will receive the config values at the paths listed in inputs. Each output
-- from f will go into one of the output paths.
function addMod(inputs, outputs, f)
    local allMods = Declua.allMods
    local allOptions = Declua.allOptions
    local wrapped = function(config)
        local inputValues = {}
        for _, input in ipairs(inputs) do
            -- Traverse the input path through the config.
            local value = config
            for _, name in ipairs(input) do
                if value == nil then
                    value = {}
                else
                    value = value[name]
                end
            end
            inputValues[#inputValues + 1] = value
        end

        -- Convert back and forth between lists and multiple results/arguments.
        local outputValues = {f(unpack(inputValues))}

        for i, output in ipairs(outputs) do
            local value = config
            local values = {}
            for j, name in ipairs(output) do
                -- Traverse the output path through the config. This is a
                -- little more complicated because we want to store values at
                -- the output and might have to backtrack if the output is
                -- inside an option.
                if j == #output then
                    local asString = table.concat(output, "/")
                    local outSize = #output
                    local realValue = outputValues[i]
                    -- This is the backtracking code. For example, the user
                    -- might output to "/config/treesitter/highlight/enable"
                    -- because they want to be as specific as possible. The
                    -- nearest option is "/config/treesitter" which defines the
                    -- dictionary passed to the treesitter setup function. This
                    -- code will backtracke the output path to the nearest
                    -- option. TODO Is it more efficient to keep track of the
                    -- most recent parent option as you go instead of
                    -- backtracking?
                    while not allOptions[asString] do
                        realValue = { [output[outSize]] = realValue }
                        value = values[#values]
                        values[#values] = nil
                        outSize = outSize - 1
                        name = output[outSize]
                        asString = table.concat({unpack(output, 1, outSize)}, "/")
                    end
                    if not typeCheck(allOptions[asString], realValue) then
                        error("Type check failed at " .. asString.."\nGot " .. dump(realValue))
                    end
                    value[name] = mergeType(allOptions[asString], value[name], realValue)
                else
                    if value[name] == nil then
                        value[name] = {}
                    end
                    values[#values + 1] = value
                    value = value[name]
                end
            end
        end
    end
    allMods[#allMods + 1] = {inputs = inputs, outputs = outputs, f = wrapped}
end

return { addMod = addMod }
