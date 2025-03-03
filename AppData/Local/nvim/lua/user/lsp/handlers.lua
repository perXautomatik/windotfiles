local M = {}

-- :LspInfo border
require("lspconfig.ui.windows").default_options.border = "single"

-- TODO: backfill this to template
M.setup = function()
  local signs = {
    { name = "DiagnosticSignError", text = "✘" },
    { name = "DiagnosticSignWarn", text = "▲" },
    { name = "DiagnosticSignHint", text = "⚑" },
    { name = "DiagnosticSignInfo", text = "" },
  }

  for _, sign in ipairs(signs) do
    vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
  end

  local config = {
    -- virtual_text = { prefix = "" },
    -- disable virtual text
    virtual_text = false,
    -- show signs
    signs = {
      active = signs,
    },
    update_in_insert = false,
    underline = true,
    severity_sort = true,
    float = {
      focusable = true,
      style = "minimal",
      border = "rounded",
      source = "always",
      header = "",
      prefix = "",
    },
  }

  vim.diagnostic.config(config)

  -- vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
  --   border = "rounded",
  -- })

  -- disable notifications in vim.lsp.buf.hover
  -- from: https://github.com/neovim/neovim/issues/20457
  vim.lsp.handlers["textDocument/hover"] = function(_, result, ctx, config)
    config = config or { border = "rounded" }
    config.focus_id = ctx.method
    if not (result and result.contents) then
      return
    end
    local markdown_lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
    markdown_lines = vim.lsp.util.trim_empty_lines(markdown_lines)
    if vim.tbl_isempty(markdown_lines) then
      return
    end
    return vim.lsp.util.open_floating_preview(markdown_lines, "markdown", config)
  end

  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
    border = "rounded",
  })
end

local opts = { noremap = true, silent = true }
local map = vim.keymap.set
map("n", "<leader>dg", vim.diagnostic.open_float, opts)
map("n", "<leader>dq", vim.diagnostic.setloclist, opts)
map("n", "<M-F>", function()
  vim.lsp.buf.format({ async = true })
end, opts)
map("v", "<M-F>", function()
  vim.lsp.buf.format({ async = true, range = true })
end)
map("n", "<leader>li", "<Cmd>LspInfo<CR>")
map("n", "<leader>lm", "<Cmd>Mason<CR>")
map("n", "<leader>ln", "<Cmd>NullLsInfo<CR>")

-- toggle LSP diagnostics
vim.g.diagnostics_active = true
map("n", "<leader>td", function()
  vim.g.diagnostics_active = not vim.g.diagnostics_active
  if vim.g.diagnostics_active then
    vim.diagnostic.enable()
  else
    vim.diagnostic.disable()
  end
end, { desc = "toggle LSP diagnostics" })

local function lsp_keymaps(bufnr)
  local bufopts = { noremap = true, silent = true, buffer = bufnr }

  map("n", "K", vim.lsp.buf.hover, bufopts)
  map("n", "gd", vim.lsp.buf.definition, bufopts)
  map("n", "gD", vim.lsp.buf.declaration, bufopts)
  map("n", "gI", vim.lsp.buf.implementation, bufopts)
  map("n", "gR", vim.lsp.buf.references, bufopts)
  map({ "n", "i" }, "<M-/>", vim.lsp.buf.signature_help, bufopts)
  -- map("n", "<leader>rn", vim.lsp.buf.rename, bufopts)
  map("n", "<leader>rn", ":lua require('user.essentials').lspRename()<CR>", bufopts)
  map("n", "<leader>ca", vim.lsp.buf.code_action, bufopts)
  map("n", "<leader>lT", vim.lsp.buf.type_definition, bufopts)
  map("n", "<leader>wl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, bufopts)
  map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.api.nvim_create_user_command("Format", function()
    vim.lsp.buf.format({ async = true })
  end, {})
end

M.on_attach = function(client, bufnr)
  -- Make omnicomplete use LSP completions
  -- vim.bo.omnifunc = "v:lua.vim.lsp.omnifunc"

  local navic_status_ok, navic = pcall(require, "nvim-navic")
  if not navic_status_ok then
    print("nvim-navic not found")
    return
  end

  -- attach nvim-navic
  if client.server_capabilities.documentSymbolProvider and client.name ~= "astro" then
    navic.attach(client, bufnr)
  end

  if client.name == "sumneko_lua" or client.name == "tsserver" or client.name == "html" then
    client.server_capabilities.documentFormattingProvider = false
  end

  lsp_keymaps(bufnr)
end

local status_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not status_ok then
  return
end

M.capabilities = cmp_nvim_lsp.default_capabilities()

return M
