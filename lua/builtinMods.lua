require "modsHelper"



-- Control vim options from Declua.
addOption({"config", "vim", "o"}, shallowTable)
addMod({{"config", "vim", "o"}}, {}, function(o)
    for oName, oValue in pairs(o) do
        vim.o[oName] = oValue
    end
end)


-- Setup LSPConfig based on a list of servers the user wants to use.
addPlugin("lspconfig", { name = "neovim/nvim-lspconfig" }, { lspconfig = "lspconfig" })
addOption({"config", "lsp", "supported"}, array)
addMod({Declua.plugins.lspconfig.loaded, Declua.plugins.lspconfig.enable, {"config", "lsp", "supported"}}, {}, function(_, enabled, o)
    if enabled then
        for _, oValue in ipairs(o) do
            Declua.requires.lspconfig[oValue].setup{}
        end
    end
end)


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


-- Random other lsp plugins
addPlugin("lspstatus", { name = "nvim-lua/lsp-status.nvim" })
addPlugin("compe", { name = "hrsh7th/nvim-compe" })
addPlugin("lspinstall", { name = "kabouzeid/nvim-lspinstall" })



-- Enable all the lsp plugins in one go.
local lspToEnable = {
    Declua.plugins.lspconfig.enable,
    Declua.plugins.lspsaga.enable,
    Declua.plugins.lspstatus.enable,
    Declua.plugins.compe.enable,
    Declua.plugins.lspinstall.enable,
}
addOption({"config", "lsp", "enable"}, bool)
addMod({{"config", "lsp", "enable"}}, lspToEnable, function(enabled)
    return enabled, enabled, enabled, enabled, enabled
end)


-- Setup treesitter
-- addPlugin("treesitter", { name = "nvim-treesitter/nvim-treesitter", options = { run = ":TSUpdate" }}, {}, function(o)
--     require'nvim-treesitter.configs'.setup(o)
-- end, {[{"config", "treesitter"}] = shallowTable})


-- Use packer to manage imports
addOption(importFinished, unit)
addOption({"import"}, shallowTable)
addMod({{"import"}}, {{"__finished__", "import"}}, function(packages)
    require('packer').startup(function()
        for plugin, opts in pairs(packages) do
            opts[1] = plugin
            use(opts)
        end
    end)
    require('packer').compile()
    return nil
end)

-- TODO Keybindigs and plenty of other stuff.
