-- Packer will output to importFinished once all packages load. Anything that
-- needs to run after packages load can use this as an input.
-- TODO this shouldn't be global
importFinished = {"__finished__", "import"}

-- Creates a "module" for a plugin with a bunch of options and defaults. I'm not totally happy with the ergonomics, but it's not bad.
addPlugin = function(name, packerDefault, required, onLoad, loadOptions)
    local enablePath = {"config", "plugins", name, "enable"}
    addOption(enablePath, bool)


    local packerPath = {"config", "plugins", name, "packer"}
    addOption(packerPath, str)

    local loadedPath = {"__loaded__", name}
    addOption(loadedPath, unit)

    if not Declua.plugins then
        Declua.plugins = {}
    end
    Declua.plugins[name] = { enable = enablePath, loaded = loadedPath }

    local enableMod = function(enable, packer)
        -- Are these three lines idiomatic?
        packer = packer or packerDefault
        packer.name = packer.name or packerDefault.name
        packer.options = packer.options or packerDefault.options or {}

        if enable then
            return {
                [packer.name] = packer.options,
            }
        else
            return {}
        end
    end

    local loadedMod = function(_, enable, ...)
        if enable then
            if not Declua.requires then
                Declua.requires = {}
            end
            if onLoad then
                onLoad(...)
            end
            for globalName, stringToRequire in pairs(required or {}) do
                Declua.requires[globalName] = require(stringToRequire)
            end
        end
        return nil
    end

    addMod({enablePath, packerPath}, {{"import"}}, enableMod)
    local loadExtraPaths = {}
    for name, t in pairs(loadOptions or {}) do
        table.insert(loadExtraPaths, name)
        addOption(name, t)
    end
    addMod({importFinished, enablePath, unpack(loadExtraPaths)}, {loadedPath}, loadedMod)
end
