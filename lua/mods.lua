function typeCheck(t, value)
    local mt = getmetatable(value)
    if mt and mt.__wrapper then
        value = mt.__typeCheck(t)
    end
    return t.isValid(value)
end

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

function addMod(inputs, outputs, f)
    local allMods = Declua.allMods
    local allOptions = Declua.allOptions
    local wrapped = function(config)
        local inputValues = {}
        for _, input in ipairs(inputs) do
            local value = config
            for _, name in ipairs(input) do
                if value[name] == nil then
                    value[name] = {}
                end
                value = value[name]
            end
            inputValues[#inputValues + 1] = value
        end
        local outputValues = {f(unpack(inputValues))}

        for i, output in ipairs(outputs) do
            local value = config
            local values = {}
            for j, name in ipairs(output) do
                if j == #output then
                    local asString = table.concat(output, "/")
                    local outSize = #output
                    local realValue = outputValues[i]
                    while not allOptions[asString] do
                        realValue = { [output[outSize]] = realValue }
                        value = values[#values]
                        values[#values] = nil
                        outSize = outSize - 1
                        name = output[outSize]
                        asString = table.concat({unpack(output, 1, outSize)}, "/")
                    end
                    assert(typeCheck(allOptions[asString], realValue) == true)
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
