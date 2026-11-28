-- With a controller, a focused text field takes the D-pad and B, so the cursor
-- can't leave it and the mailbox can't be closed. The game focuses the To field
-- by itself when the Send Mail tab opens and after each sent mail (forever branch:
-- MailFrame.xml SendMailFrame OnShow, MailFrame.lua SendMailFrame_Reset). This
-- releases it right after, only while the controller is in use; A on the field
-- still lets you type.
-- It never listens to controller buttons: a frame with an OnGamePadButtonDown
-- script takes every button for itself, and the cursor stops moving (seen
-- 2026-11-24). It never joins the game's controller window list either.
local _, addon = ...
local Focus = {}
addon.Focus = Focus

function Focus.ControllerInUse()
    return C_InputInterfaceStyle ~= nil and Enum.InputDeviceInterfaceType ~= nil
        and C_InputInterfaceStyle.GetCurrentStyle() == Enum.InputDeviceInterfaceType.Gamepad
end

-- After the game focused To by itself.
function Focus.ReleaseToField()
    if Focus.ControllerInUse() and SendMailNameEditBox:HasFocus() then SendMailNameEditBox:ClearFocus() end
end

function Focus.Hook()
    if not (SendMailFrame and SendMailNameEditBox) or Focus.hooked then return end
    Focus.hooked = true
    SendMailFrame:HookScript("OnShow", Focus.ReleaseToField)
    if type(SendMailFrame_Reset) == "function" then hooksecurefunc("SendMailFrame_Reset", Focus.ReleaseToField) end
end
