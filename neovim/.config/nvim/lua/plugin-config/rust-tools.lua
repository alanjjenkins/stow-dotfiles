local function exists(file)
  local ok, err, code = os.rename(file, file)
  if not ok then
    if code == 13 then
      -- Permission denied, but it exists
      return true
    end
  end
  return ok, err
end

--- Check if a directory exists in this path
local function isdir(path)
  -- "/" works on both Unix and Windows
  return exists(path .. "/")
end

local dap = {}
local code_lldb_extension_path = vim.env.HOME .. "/.local/share/nvim/mason/packages/codelldb/"

local codelldb_path = code_lldb_extension_path .. "extension/adapter/codelldb"
local liblldb_path = code_lldb_extension_path .. "extension/lldb/lib/liblldb.so"

dap = {
  adapter = require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path),
}

local rt = require("rust-tools")
local ih = require("inlay-hints")

rt.setup({
  tools = {
    on_initialized = function()
      ih.set_all()
    end,
    inlay_hints = {
      auto = false,
    },
  },
  server = {
    standalone = true,
    on_attach = function(context, bufnr)
      -- Hover actions
      vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })

      -- Code action groups
      vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })

      ih.on_attach(context, bufnr)
    end,
    ["rust-analyzer"] = {
      checkOnSave = {
        command = "clippy",
      },
    },
  },

  -- debugging stuff
  dap = dap,
})
