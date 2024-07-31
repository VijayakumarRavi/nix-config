local config_path = vim.fn.stdpath("config")
-- Define the paths
local home = os.getenv("HOME")
local default_config_path = home .. "/.config/nvim"
local default_data_path = home .. "/.local/share/nvim"
local dev_data_path = home .. "/.local/share/dev_nvim"

local data_path
local lazypath

if config_path == default_config_path then
  data_path = default_data_path
else
  data_path = dev_data_path
end

vim.fn.setenv("XDG_DATA_HOME", data_path)
lazypath = data_path .. "/lazy/lazy.nvim"

print("Data path set to: " .. vim.fn.getenv("XDG_DATA_HOME"))

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("vim-options")
require("lazy").setup("plugins")
