-- herdr-nvim: the nvim half of the herdr sidebar integration.
--
-- The herdr half (full-height nvim sidebar + agent-touched file picker) is a
-- herdr plugin, bound to prefix+alt+e / prefix+alt+o in ~/.config/herdr/config.toml.
-- This spec adds the other half: annotate lines or a selection like a code review,
-- then send them all to the agent in the sibling pane with file:line and git context.
--
-- <leader>ac comment / <leader>al list / <leader>as paste / <leader>aS submit
--
-- Note: this occupies the <leader>a prefix, so the LazyVim `ai.claudecode` extra
-- is deliberately not enabled - it maps <leader>ac and <leader>as to its own
-- actions, and it would attach a second Claude session over ~/.claude/ide/*.lock
-- instead of reusing the one herdr already manages in the pane.
return {
  { "ChmaraX/herdr-nvim", opts = {} },
}
