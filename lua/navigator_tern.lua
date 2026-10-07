---Navigator.nvim multiplexer for Tern panes (the tmux mux's job when nvim runs straight in Tern).
---Tern's `tmux-parity` plugin sends Ctrl-h/j/k/l to nvim; at an nvim edge this moves Tern's focus.
---@class TernMux: Vi
local Tern = require("Navigator.mux.vi"):new()

local EPS = 1e-6

local function tern(args)
  local res = vim.system(vim.list_extend({ "tern" }, args), { text = true }):wait()
  if res.code ~= 0 then
    return nil
  end
  return res.stdout
end

---Lays the split tree out on the unit square: one {id, x, y, w, h} per pane.
local function layout(node, x, y, w, h, out)
  if node.Leaf then
    out[#out + 1] = { id = node.Leaf, x = x, y = y, w = w, h = h }
  elseif node.Split then
    local s = node.Split
    if s.axis == "Row" then
      local wa = w * s.ratio
      layout(s.a, x, y, wa, h, out)
      layout(s.b, x + wa, y, w - wa, h, out)
    else
      local ha = h * s.ratio
      layout(s.a, x, y, w, ha, out)
      layout(s.b, x, y + ha, w, h - ha, out)
    end
  end
  return out
end

local function overlap(a0, a1, b0, b1)
  return math.min(a1, b1) - math.max(a0, b0)
end

---The tab holding this pane, from `tern ls --json`.
local function current_tab(pane)
  local out = tern({ "ls", "--json" })
  if not out then
    return nil
  end
  for _, session in ipairs(vim.json.decode(out).sessions or {}) do
    for _, tab in ipairs(session.tabs or {}) do
      for _, block in ipairs(tab.blocks or {}) do
        if block.id == pane then
          return tab
        end
      end
    end
  end
end

---Creates the Tern navigator; errors outside a Tern pane.
---@return TernMux
function Tern:new()
  assert(vim.env.TERN_PANE, "[Navigator] not in a Tern pane")
  local state = { pane = tonumber(vim.env.TERN_PANE) }
  self.__index = self
  return setmetatable(state, self)
end

function Tern:zoomed()
  local tab = current_tab(self.pane)
  return tab ~= nil and tab.zoomed == true
end

---The pane id beside this one in `direction` (h/j/k/l), or nil at the window's edge.
---@param direction string
---@return number?
function Tern:target(direction)
  local tab = current_tab(self.pane)
  if not tab or not tab.splits then
    return nil
  end
  local panes = layout(tab.splits, 0, 0, 1, 1, {})
  local cur
  for _, p in ipairs(panes) do
    if p.id == self.pane then
      cur = p
    end
  end
  if not cur then
    return nil
  end
  local best, best_overlap, best_pos
  for _, p in ipairs(panes) do
    local touches, shared, pos
    if direction == "h" then
      touches, shared, pos = math.abs(p.x + p.w - cur.x) < EPS, overlap(p.y, p.y + p.h, cur.y, cur.y + cur.h), p.y
    elseif direction == "l" then
      touches, shared, pos = math.abs(cur.x + cur.w - p.x) < EPS, overlap(p.y, p.y + p.h, cur.y, cur.y + cur.h), p.y
    elseif direction == "k" then
      touches, shared, pos = math.abs(p.y + p.h - cur.y) < EPS, overlap(p.x, p.x + p.w, cur.x, cur.x + cur.w), p.x
    elseif direction == "j" then
      touches, shared, pos = math.abs(cur.y + cur.h - p.y) < EPS, overlap(p.x, p.x + p.w, cur.x, cur.x + cur.w), p.x
    end
    if touches and shared > EPS and (not best or shared > best_overlap + EPS or (math.abs(shared - best_overlap) < EPS and pos < best_pos)) then
      best, best_overlap, best_pos = p.id, shared, pos
    end
  end
  return best
end

---@param direction string
---@return TernMux
function Tern:navigate(direction)
  local id = self:target(direction)
  if id then
    vim.system({ "tern", "focus", string.format("%d", id) })
  end
  return self
end

return Tern
