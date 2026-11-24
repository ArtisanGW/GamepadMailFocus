-- Gamepad Mail Focus with stand-ins for the game. From the repo root: luajit tests/run.lua
local failures = 0
local function check(condition, message)
    if condition then print("ok   " .. message) else failures = failures + 1; print("FAIL " .. message) end
end

local function frame(parent)
    local fake = { parent = parent, scripts = {}, hooks = {} }
    function fake:GetParent() return self.parent end
    function fake:SetScript(name, handler) self.scripts[name] = handler end
    -- every hook of a script runs, in the order they were added
    function fake:HookScript(name, handler)
        local previous = self.hooks[name]
        self.hooks[name] = previous and function(...) previous(...); handler(...) end or handler
    end
    function fake:RegisterEvent() end
    return fake
end
local keyboardFocus
local function editBox(parent)
    local box = frame(parent)
    function box:SetFocus() keyboardFocus = self end
    function box:ClearFocus() if keyboardFocus == self then keyboardFocus = nil end end
    function box:HasFocus() return keyboardFocus == self end
    return box
end

local style = 2
Enum = { InputDeviceInterfaceType = { Mkb = 1, Gamepad = 2 } }
C_InputInterfaceStyle = { GetCurrentStyle = function() return style end }
GetCurrentKeyBoardFocus = function() return keyboardFocus end
SendMailFrame = frame(nil)
SendMailNameEditBox = editBox(SendMailFrame)
SendMailBodyEditBox = editBox(frame(SendMailFrame))
ChatEditBox = editBox(nil)
local frames = {}
CreateFrame = function(_, _, parent) local made = frame(parent); frames[#frames + 1] = made; return made end
local resetHooks = {}
SendMailFrame_Reset = function() end
hooksecurefunc = function(name, hook) resetHooks[name] = hook end
SlashCmdList = {}
DEFAULT_CHAT_FRAME = { AddMessage = function() end }

local addon = {}
for line in io.lines("GamepadMailFocus.toc") do
    line = line:gsub("\r", "")
    if line:match("%.lua$") then assert(loadfile(line))("GamepadMailFocus", addon) end
end
local events = frames[1]
events.scripts.OnEvent(events, "ADDON_LOADED", "GamepadMailFocus")
events.scripts.OnEvent(events, "PLAYER_LOGIN")

-- The game opens Send Mail and focuses To; the addon releases it.
SendMailNameEditBox:SetFocus(); SendMailFrame.hooks.OnShow()
check(keyboardFocus == nil, "Send Mail opening: To is released")
SendMailNameEditBox:SetFocus(); resetHooks.SendMailFrame_Reset()
check(keyboardFocus == nil, "after a sent mail: To is released")

-- A field the player chose stays focused: only the game's own autofocus is released.
SendMailBodyEditBox:SetFocus(); resetHooks.SendMailFrame_Reset()
check(keyboardFocus == SendMailBodyEditBox, "a field the player chose keeps the focus")

-- With mouse and keyboard, the game's focus stays as it is.
style = 1; SendMailNameEditBox:SetFocus(); SendMailFrame.hooks.OnShow()
check(keyboardFocus == SendMailNameEditBox, "mouse and keyboard: To keeps the focus")

-- Vanilla: no other addon.
local toc = io.open("GamepadMailFocus.toc"):read("*a")
check(not toc:find("Dependencies") and not toc:find("OptionalDeps"), "no other addon in the toc")

if failures > 0 then print(failures .. " failed"); os.exit(1) end
print("all tests passed")
