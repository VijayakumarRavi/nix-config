vim.g.mapleader = " "
vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")

vim.wo.number = true
vim.wo.wrap = false

-- Search
vim.o.hlsearch = false
vim.o.incsearch = true
vim.o.ignorecase = true

-- Always keep 10 lines above/below cursor unless at start/end of file
vim.wo.scrolloff = 10

-- Disable mode indicator
vim.o.showmode = false

-- Enable spell check
vim.opt.spell = true
vim.opt.spelllang = "en_us"
vim.opt.spellsuggest=best,9 -- Don't show too much suggestion for spell check.
vim.opt.spellfile="/home/vijay/.local/share/nvim/spell_add/en.utf-8.add"

vim.opt.clipboard = "unnamedplus"

-- Set colorscheme
vim.cmd([[colorscheme habamax]])

-- Enable persistent undo history
vim.cmd([[
    if has("persistent_undo")
      let target_path = expand('~/.cache/undodir')

       " create the directory and any parent directories
       " if the location does not exist.
       if !isdirectory(target_path)
           call mkdir(target_path, "p", 0700)
       endif

       let &undodir=target_path
       set undofile
    endif
]])

-- Remember last cursor position
-- When editing a file, always jump to the last known cursor position.
-- Don't do it when the position is invalid, when inside an event handler,
-- for a commit or rebase message
-- (likely a different one than last time), and when using xxd(1) to filter
-- and edit binary files (it transforms input files back and forth, causing
-- them to have dual nature, so to speak)

function RestoreCursorPosition()
	local line = vim.fn.line("'\"")
	if
		line > 1
		and line <= vim.fn.line("$")
		and vim.bo.filetype ~= "commit"
		and vim.fn.index({ "xxd", "gitrebase" }, vim.bo.filetype) == -1
	then
		vim.cmd('normal! g`"')
	end
end

if vim.fn.has("autocmd") then
	vim.cmd([[autocmd BufReadPost * lua RestoreCursorPosition()]])
end

-- Keymaps
-- Navigate vim panes better
vim.keymap.set("n", "<c-k>", ":wincmd k<CR>")
vim.keymap.set("n", "<c-j>", ":wincmd j<CR>")
vim.keymap.set("n", "<c-h>", ":wincmd h<CR>")
vim.keymap.set("n", "<c-l>", ":wincmd l<CR>")

-- control+s to save
vim.keymap.set("n", "<c-s>", ":w<CR>")
vim.keymap.set("v", "<c-s>", "<esc>:w<CR>")
vim.keymap.set("i", "<c-s>", "<esc>:w<CR>")
