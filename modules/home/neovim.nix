{ pkgs, ... }:

{
  programs.neovim = {
    # LSP servers and tools available to neovim
    extraPackages = with pkgs; [
      # LSP servers
      yaml-language-server
      bash-language-server
      marksman
      rust-analyzer
      nil
      lua-language-server
      taplo

      # required by telescope-fzf-native
      gcc
      gnumake

      # used by various plugins
      ripgrep
      fd
    ];

    plugins = with pkgs.vimPlugins; [
      # ── Theme ──────────────────────────────────────────────────────────
      catppuccin-nvim

      # ── UI ─────────────────────────────────────────────────────────────
      lualine-nvim
      bufferline-nvim
      noice-nvim
      nvim-notify
      which-key-nvim
      gitsigns-nvim
      indent-blankline-nvim
      todo-comments-nvim
      nvim-web-devicons

      # ── Navigation ─────────────────────────────────────────────────────
      oil-nvim
      telescope-nvim
      telescope-fzf-native-nvim
      telescope-ui-select-nvim
      plenary-nvim

      # ── Editing ────────────────────────────────────────────────────────
      nvim-treesitter.withAllGrammars
      nvim-autopairs
      comment-nvim

      # ── LSP ────────────────────────────────────────────────────────────
      nvim-lspconfig

      # ── Completion ─────────────────────────────────────────────────────
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp_luasnip
      luasnip
    ];

    initLua = ''
      -- ── Options ──────────────────────────────────────────────────────────
      vim.g.mapleader      = " "
      vim.g.maplocalleader = " "

      local opt = vim.opt
      opt.number         = true
      opt.relativenumber = true
      opt.expandtab      = true
      opt.shiftwidth     = 2
      opt.tabstop        = 2
      opt.smartindent    = true
      opt.wrap           = false
      opt.ignorecase     = true
      opt.smartcase      = true
      opt.incsearch      = true
      opt.hlsearch       = false
      opt.termguicolors  = true
      opt.signcolumn     = "yes"
      opt.updatetime     = 250
      opt.splitright     = true
      opt.splitbelow     = true
      opt.scrolloff      = 8
      opt.sidescrolloff  = 8
      opt.clipboard      = "unnamedplus"
      opt.undofile       = true
      opt.cursorline     = true
      opt.showmode       = false   -- lualine shows the mode
      opt.mouse          = ""      -- disable mouse

      -- ── Theme ────────────────────────────────────────────────────────────
      require("catppuccin").setup({
        flavour          = "mocha",
        transparent_background = false,
        integrations = {
          cmp            = true,
          gitsigns       = true,
          telescope      = { enabled = true },
          treesitter     = true,
          which_key      = true,
          bufferline     = true,
          indent_blankline = { enabled = true },
          noice          = true,
          notify         = true,
          lsp_trouble    = false,
          native_lsp = {
            enabled = true,
            underlines = {
              errors      = { "underline" },
              hints       = { "underline" },
              warnings    = { "underline" },
              information = { "underline" },
            },
          },
        },
      })
      vim.cmd.colorscheme("catppuccin")

      -- ── Noice ────────────────────────────────────────────────────────────
      require("noice").setup({
        lsp = {
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"]                = true,
            ["cmp.entry.get_documentation"]                  = true,
          },
        },
        presets = {
          bottom_search        = true,
          command_palette      = true,
          long_message_to_split = true,
        },
      })

      -- ── Notify ───────────────────────────────────────────────────────────
      require("notify").setup({
        background_colour = "#1e1e2e",
        render            = "compact",
        timeout           = 3000,
      })

      -- ── Lualine ──────────────────────────────────────────────────────────
      require("lualine").setup({
        options = {
          theme                = "catppuccin",
          component_separators = { left = "", right = "" },
          section_separators   = { left = "", right = "" },
          globalstatus         = true,
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { { "filename", path = 1 } },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      })

      -- ── Bufferline ───────────────────────────────────────────────────────
      require("bufferline").setup({
        options = {
          diagnostics             = "nvim_lsp",
          show_buffer_close_icons = false,
          show_close_icon         = false,
          separator_style         = "thin",
        },
      })

      -- ── Gitsigns ─────────────────────────────────────────────────────────
      require("gitsigns").setup({
        signs = {
          add          = { text = "▎" },
          change       = { text = "▎" },
          delete       = { text = "" },
          topdelete    = { text = "" },
          changedelete = { text = "▎" },
          untracked    = { text = "▎" },
        },
      })

      -- ── Indent blankline ─────────────────────────────────────────────────
      require("ibl").setup({
        indent = { char = " " },
        scope  = { enabled = true },
      })

      -- ── Todo comments ────────────────────────────────────────────────────
      require("todo-comments").setup()

      -- ── Which-key ────────────────────────────────────────────────────────
      require("which-key").setup()

      -- ── Oil ──────────────────────────────────────────────────────────────
      require("oil").setup({
        default_file_explorer = true,
        delete_to_trash       = true,
        view_options = {
          show_hidden = true,
        },
        keymaps = {
          ["<C-s>"] = false,  -- disable split so it doesn't conflict
          ["<C-h>"] = false,
        },
      })

      -- ── Telescope ────────────────────────────────────────────────────────
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          prompt_prefix   = "  ",
          selection_caret = " ",
          path_display    = { "truncate" },
          sorting_strategy = "ascending",
          layout_config = {
            horizontal = { prompt_position = "top", preview_width = 0.55 },
          },
        },
        extensions = {
          fzf = {
            fuzzy                   = true,
            override_generic_sorter = true,
            override_file_sorter    = true,
          },
        },
      })
      telescope.load_extension("fzf")
      telescope.load_extension("ui-select")

      -- ── Treesitter ───────────────────────────────────────────────────────
      require("nvim-treesitter.configs").setup({
        highlight    = { enable = true },
        indent       = { enable = true },
        auto_install = false,
      })

      -- ── Autopairs ────────────────────────────────────────────────────────
      require("nvim-autopairs").setup()

      -- ── Comment ──────────────────────────────────────────────────────────
      require("Comment").setup()

      -- ── LSP ──────────────────────────────────────────────────────────────
      local lspconfig   = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local servers = {
        yamlls        = {},
        bashls        = {},
        marksman      = {},
        rust_analyzer = {},
        nil_ls        = {},
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = { globals = { "vim" } },
              workspace   = { checkThirdParty = false },
              telemetry   = { enable = false },
            },
          },
        },
        taplo = {},
      }

      for server, config in pairs(servers) do
        config.capabilities = capabilities
        lspconfig[server].setup(config)
      end

      -- LSP keymaps (set on attach)
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = ev.buf, desc = "LSP: " .. desc })
          end
          map("gd",          vim.lsp.buf.definition,      "Go to definition")
          map("gD",          vim.lsp.buf.declaration,     "Go to declaration")
          map("gr",          vim.lsp.buf.references,      "Go to references")
          map("gi",          vim.lsp.buf.implementation,  "Go to implementation")
          map("K",           vim.lsp.buf.hover,           "Hover docs")
          map("<leader>rn",  vim.lsp.buf.rename,          "Rename")
          map("<leader>ca",  vim.lsp.buf.code_action,     "Code action")
          map("<leader>d",   vim.diagnostic.open_float,   "Show diagnostics")
          map("[d",          vim.diagnostic.goto_prev,    "Prev diagnostic")
          map("]d",          vim.diagnostic.goto_next,    "Next diagnostic")
        end,
      })

      -- ── Completion ───────────────────────────────────────────────────────
      local cmp     = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"]     = cmp.mapping.scroll_docs(-4),
          ["<C-f>"]     = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"]     = cmp.mapping.abort(),
          ["<CR>"]      = cmp.mapping.confirm({ select = false }),
          ["<Tab>"]     = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else fallback() end
          end, { "i", "s" }),
          ["<S-Tab>"]   = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then luasnip.jump(-1)
            else fallback() end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
        formatting = {
          format = function(_, item)
            local icons = {
              Text          = "󰊄", Method      = "󰆧", Function    = "󰊕",
              Constructor   = "", Field        = "󰜢", Variable    = "󰀫",
              Class         = "󰠱", Interface   = "", Module      = "",
              Property      = "󰜢", Unit        = "󰑭", Value       = "󰎠",
              Enum          = "", Keyword      = "󰌋", Snippet     = "",
              Color         = "󰏘", File        = "󰈙", Reference   = "󰈇",
              Folder        = "󰉋", EnumMember  = "", Constant    = "󰏿",
              Struct        = "󰙅", Event       = "", Operator    = "󰆕",
              TypeParameter = "󰊄",
            }
            item.kind = string.format("%s %s", icons[item.kind] or "", item.kind)
            return item
          end,
        },
      })

      -- ── Keymaps ──────────────────────────────────────────────────────────
      local map = function(mode, keys, func, desc)
        vim.keymap.set(mode, keys, func, { desc = desc })
      end

      local builtin = require("telescope.builtin")

      -- files
      map("n", "<leader>ff", builtin.find_files,               "Find files")
      map("n", "<leader>fg", builtin.live_grep,                "Live grep")
      map("n", "<leader>fb", builtin.buffers,                  "Find buffers")
      map("n", "<leader>fh", builtin.help_tags,                "Help tags")
      map("n", "<leader>fd", builtin.diagnostics,              "Diagnostics")
      map("n", "<leader>fr", builtin.oldfiles,                 "Recent files")
      map("n", "<leader>fs", builtin.lsp_document_symbols,     "Document symbols")

      -- oil
      map("n", "-",          "<cmd>Oil<cr>",                   "Open parent dir (oil)")
      map("n", "<leader>e",  "<cmd>Oil<cr>",                   "Open parent dir (oil)")

      -- buffers
      map("n", "<Tab>",      "<cmd>BufferLineCycleNext<cr>",   "Next buffer")
      map("n", "<S-Tab>",    "<cmd>BufferLineCyclePrev<cr>",   "Prev buffer")
      map("n", "<leader>bd", "<cmd>bdelete<cr>",               "Delete buffer")

      -- splits
      map("n", "<leader>sv", "<cmd>vsplit<cr>",                "Vertical split")
      map("n", "<leader>sh", "<cmd>split<cr>",                 "Horizontal split")

      -- misc
      map("n", "<leader>nh", "<cmd>nohlsearch<cr>",            "Clear search highlight")
      map("n", "<leader>w",  "<cmd>write<cr>",                 "Save file")
      map("n", "<leader>q",  "<cmd>quit<cr>",                  "Quit")
    '';
  };
}
