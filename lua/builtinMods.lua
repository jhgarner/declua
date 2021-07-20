local importFinished = {"__finished__", "import"}

-- 1
addMod({{"config", "vim", "o"}}, {}, function(o)
    for oName, oValue in pairs(o) do
        vim.o[oName] = oValue
    end
end)

-- 2
-- Make sure import is called before config
addMod({{"__finished__", "import"}}, {{"require"}}, function(_)
    return {}
end)

addMod({{"require"}}, {{"__finished__", "require"}}, function(req)
    Declua.requires = {}
    local finished = {}
    for plugin, requires in pairs(req) do
        for globalName, stringToRequire in pairs(requires) do
            Declua.requires[globalName] = require(stringToRequire)
        end
        finished[plugin] = {}
    end
    return finished
end)



-- args contains:
-- name (required) = Plugin name
-- packer (required) = Packer path
--
function addPlugin(name, packerDefault, required, onLoad, loadOptions)
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

    local loadedMod = function(enable, packer, ...)
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

addPlugin("lspconfig", { name = "neovim/nvim-lspconfig" }, { lspconfig = "lspconfig" })

addPlugin("lspsaga", { name = "glepnir/lspsaga.nvim" }, {
        lspsagaprovider = 'lspsaga.provider',
        lspsagacodeaction = 'lspsaga.codeaction',
        lspsagahover = 'lspsaga.hover',
        lspsagaaction = 'lspsaga.action',
        lspsagasignaturehelp = 'lspsaga.signaturehelp',
        lspsagaprovider = 'lspsaga.provider',
        lspsagadiagnostic = 'lspsaga.diagnostic',
    }, function()
        require 'lspsaga'.init_lsp_saga()
end)

addPlugin("treesitter", { name = "nvim-treesitter/nvim-treesitter", options = { run = ":TSUpdate" }}, {}, function(o)
    require'nvim-treesitter.configs'.setup(o)
end, {[{"config", "treesitter"}] = shallowTable})

addPlugin("lspstatus", { name = "nvim-lua/lsp-status.nvim" })
addPlugin("compe", { name = "hrsh7th/nvim-compe" })
addPlugin("lspinstall", { name = "kabouzeid/nvim-lspinstall" })

addMod({Declua.plugins.lspconfig.loaded, {"config", "lsp", "supported"}}, {}, function(loaded, o)
    if loaded then
        for _, oValue in ipairs(o) do
            Declua.requires.lspconfig[oValue].setup{}
        end
    end
end)

local lspToEnable = {
    Declua.plugins.lspconfig.enable,
    Declua.plugins.lspsaga.enable,
    Declua.plugins.lspstatus.enable,
    Declua.plugins.compe.enable,
    Declua.plugins.lspinstall.enable,
}
addMod({{"config", "lsp", "enable"}}, lspToEnable, function(enabled)
    return enabled, enabled, enabled, enabled, enabled
end)

-- addMod({{"config", "keybindings", "saga", "lsp_finder"}, {}, function(key)
--     vim.api.nvim_set_keymap('n', key, '<cmd>lua lspsagacodeaction.lsp_finder()<CR>', {expr = true, noremap = true})
-- end)

-- addMod({{"config", "keybindings", "saga", "lsp_finder"}, {}, function(key)
--     vim.api.nvim_set_keymap('n', key, '<cmd>lua lspsagacodeaction.lsp_finder()<CR>', {expr = true, noremap = true})
-- end)
-- "
-- nnoremap <silent><leader>gh <cmd>lua require'lspsaga.provider'.lsp_finder()<CR>
-- nnoremap <silent> k <cmd>lua require('lspsaga.codeaction').code_action()<CR>
-- vnoremap <silent> k :<C-U>lua require('lspsaga.codeaction').range_code_action()<CR>
-- nnoremap <silent> K <cmd>lua require('lspsaga.hover').render_hover_doc()<CR>
-- nnoremap <silent> <leader>j <cmd>lua require('lspsaga.action').smart_scroll_with_saga(1)<CR>
-- nnoremap <silent> <leader>J <cmd>lua require('lspsaga.action').smart_scroll_with_saga(-1)<CR>
-- nnoremap <silent><leader>s <cmd>lua require('lspsaga.signaturehelp').signature_help()<CR>
-- nnoremap <silent><leader>r <cmd>lua require('lspsaga.rename').rename()<CR>
-- nnoremap <silent> <leader>gd <cmd>lua require'lspsaga.provider'.preview_definition()<CR>
-- nnoremap <silent><leader>d <cmd>lua require'lspsaga.diagnostic'.show_line_diagnostics()<CR>
-- nnoremap <silent> <leader>ne <cmd>lua require'lspsaga.diagnostic'.lsp_jump_diagnostic_prev()<CR>
-- nnoremap <silent> <leader>pe <cmd>lua require'lspsaga.diagnostic'.lsp_jump_diagnostic_next()<CR>
-- nnoremap <silent> <leader>f <cmd>lua vim.lsp.buf.formatting()<CR>
-- "

addMod({{"import"}}, {{"__finished__", "import"}}, function(packages)
    require('packer').startup(function()
        for plugin, opts in pairs(packages) do
            opts[1] = plugin
            use(opts)
        end
    end)
    require('packer').compile()
    return {}
end)
