-- herdr-nvim: the nvim half of the herdr sidebar integration.
--
-- The herdr half (full-height nvim sidebar + agent-touched file picker) is a
-- herdr plugin, bound to prefix+alt+e / prefix+alt+o in ~/.config/herdr/config.toml.
-- This plugin adds the other half: annotate lines or a selection like a code review,
-- then send them all to the agent in the sibling pane with file:line and git context.
--
-- <leader>ac comment / <leader>al list / <leader>as paste / <leader>aS submit
require("config.pack").add({ "ChmaraX/herdr-nvim" })
require("herdr-nvim").setup({})
