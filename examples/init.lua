require "init"
require "builtinMods"
require "builtinOptions"


-- This is an example config that should run if the lua folder in this repo is
-- in the runtime path. This really isn't meant to be used yet.
config = {
    import = {
        ['wbthomason/packer.nvim'] = {},
        ["nvim-lua/plenary.nvim"] = {},
        ['nvim-lua/popup.nvim'] = {},
        ['sheerun/vim-polyglot'] = {},
        ['jhgarner/ui-experiments'] = {
            dir = '~/code/unknown/AuraUI'
        },
        ['LnL7/vim-nix'] = {},
        ['plasticboy/vim-markdown'] = {},

        ['derekwyatt/vim-scala'] = {},
        ['rhysd/vim-grammarous'] = {},


        ['nvim-telescope/telescope.nvim'] = {},
        ['lewis6991/gitsigns.nvim'] = {},
        ['junegunn/rainbow_parentheses.vim'] = {},
        ['tpope/vim-sleuth'] = {},
        ['folke/which-key.nvim'] = {},
        ['monsonjeremy/onedark.nvim'] = {},
        ['datwaft/bubbly.nvim'] = {},
        ['hrsh7th/vim-vsnip'] = {},

        ['jhgarner/hop.nvim'] = {
            branch = 'mergedall'
        },
        ['tpope/vim-commentary'] = {},
        ['tpope/vim-surround'] = {},
    },
    config = {
        plugins = {
            lspinstall = {
                packer = {
                    name = "jhgarner/nvim-lspinstall"
                }
            }
        },
        lsp = {
            enable = true,
            supported = { "hls", "pyright", "dartls" },
        },
        treesitter = {
            highlight = {
                enable = true,
            },
            indent = {
                enable = true
            }
        },
        vim = {
            o = {
                updatetime = 300,
                shortmess = "c",
                signcolumn = "yes",
                cmdheight = 1,
                number = true,
                completeopt = "menuone,noselect",
            },
        }
    },
}

Declua.runModTree(config)
