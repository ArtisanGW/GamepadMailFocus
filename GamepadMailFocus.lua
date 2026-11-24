-- Gamepad Mail Focus
-- A vanilla addon: it uses only the game, never another addon. Its own event
-- frame, slash command (/gpmf) and saved variables (GamepadMailFocusDB).
-- What it does is in Focus.lua.
local ADDON, addon = ...

local function print(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cff66bbffGamepad Mail Focus:|r " .. message)
end

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LOGIN")
events:SetScript("OnEvent", function(_, event, name)
    if event == "ADDON_LOADED" and name == ADDON then
        GamepadMailFocusDB = GamepadMailFocusDB or {}
    elseif event == "PLAYER_LOGIN" then
        addon.Focus.Hook()
    end
end)

SLASH_GAMEPADMAILFOCUS1 = "/gpmf"
SlashCmdList.GAMEPADMAILFOCUS = function()
    print("With a controller, the Send Mail tab no longer holds the D-pad in the To field.")
    print("Press A on a field to type in it.")
end
