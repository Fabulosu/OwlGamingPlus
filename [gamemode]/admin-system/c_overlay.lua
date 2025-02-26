local sx, sy = guiGetScreenSize()
local localPlayer = getLocalPlayer()

local openReports = 0
local handledReports = 0
local ckAmount = 0
local unansweredReports = {}
local ownReports = {}

-- dx stuff
local textString = ""
local admstr = ""
local show = false

-- FPS Calculation variables
local fps = 0
local nextTick = 0

-- Admin Titles
function getAdminTitle(thePlayer)
    return exports.global:getPlayerAdminTitle(thePlayer)
end

-- Custom FPS function using provided code
function getCurrentFPS()
    return fps
end

local function updateFPS(msSinceLastFrame)
    local now = getTickCount()
    if (now >= nextTick) then
        fps = (1 / msSinceLastFrame) * 1000
        nextTick = now + 1000
    end
end
addEventHandler("onClientPreRender", root, updateFPS)

-- Update the labels
local function updateGUI()
    if show then
        local reporttext = ""
        if #unansweredReports > 0 then
            reporttext = ": #" .. table.concat(unansweredReports, ", #")
        end
        
        local ownreporttext = ""
        if #ownReports > 0 then
            ownreporttext = ": #" .. table.concat(ownReports, ", #")
        end
        
        local onduty = getElementData(localPlayer, "admin_level") <= 7 and "Off Duty | " or ""
        if getElementData(localPlayer, "duty_admin") == 1 or getElementData(localPlayer, "duty_supporter") == 1 then
            onduty = "On Duty | "
        end

        if exports.integration:isPlayerSupporter(localPlayer) or exports.integration:isPlayerTrialAdmin(localPlayer) then
            textString = getAdminTitle(localPlayer) .. " | " .. onduty .. admstr .. " | Ping: " .. getPlayerPing(localPlayer) .. " | FPS: " .. math.floor(getCurrentFPS()) .. ""
        else
            textString = getAdminTitle(localPlayer) .. " | Ping: " .. getPlayerPing(localPlayer) .. " | FPS: " .. math.floor(getCurrentFPS()) .. ""
        end
    end
end

-- Create the GUI
local function createGUI()
    show = false
    if exports.integration:isPlayerStaff(localPlayer) then
        show = true
        updateGUI()
    end
end

addEventHandler("onClientResourceStart", getResourceRootElement(), createGUI, false)
addEventHandler("onClientElementDataChange", localPlayer,
    function(n)
        if n == "admin_level" or n == "hiddenadmin" or n == "account:gmlevel" or n == "duty_supporter" or n == "duty_admin" or n == "forum_perms" then
            createGUI()
        end
    end, false
)

addEvent("updateReportsCount", true)
addEventHandler("updateReportsCount", localPlayer,
    function(open, handled, unanswered, own, admst)
        openReports = open
        handledReports = handled
        unansweredReports = unanswered
        admstr = admst
        ownReports = own or {}
        updateGUI()
    end, false
)

addEvent("addOneToCKCount", true)
addEventHandler("addOneToCKCount", localPlayer,
    function()
        ckAmount = ckAmount + 1
        updateGUI()
    end, false
)

addEvent("addOneToCKCountFromSpawn", true)
addEventHandler("addOneToCKCountFromSpawn", localPlayer,
    function()
        if (ckAmount >= 1) then
            return
        else
            ckAmount = ckAmount + 1
            updateGUI()
        end
    end, false
)

addEvent("subtractOneFromCKCount", true)
addEventHandler("subtractOneFromCKCount", localPlayer,
    function()
        if (ckAmount ~= 0) then
            ckAmount = ckAmount - 1
            updateGUI()
        else
            ckAmount = 0
        end
    end, false
)

addEventHandler("onClientPlayerQuit", getRootElement(), updateGUI)

function drawText()
    if show and exports.hud:isActive() then
        dxDrawText(textString, sx / 2 - dxGetTextWidth(textString) / 2, sy - 20, sx, sy, tocolor(255, 255, 255, 255), 1, "default-bold")
    end
end
addEventHandler("onClientRender", getRootElement(), drawText)
