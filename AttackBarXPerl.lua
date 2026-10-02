-- AttackBar an XPerl angleichen.
--
-- Das Hauptproblem ist nicht die Groesse, sondern die Optik: Abar_Frame und
-- ebar_Frame haben in Attackbar.xml ein TutorialFrameBackground als Backdrop
-- (der graue Kasten) plus einen Tooltip-Rand, und die Balken tragen den dicken
-- UI-CastingBar-Border. Eine Skalierungsoption gibt es im Addon nicht.
--
-- Dieses Addon raeumt das auf und uebernimmt XPerls Balkentextur und Breite.
-- Alles Wichtige laesst sich hier oben einstellen.

local BAR_TEX = "Interface\\AddOns\\XPerl\\Images\\XPerl_StatusBar"  -- XPerlConfig.BarTextures = 1
local BAR_H   = 9    -- Balkenhoehe
local BAR_GAP = 2    -- Abstand Main-/Offhand
local PAD     = 2    -- Abstand zum Unitframe
local FONT_SZ = 9

local function stripFrame(frame)
    if not frame then return end
    frame:SetBackdrop(nil)              -- grauer Kasten weg
    frame:EnableMouse(false)            -- nicht mehr verschiebbar, wir ankern selbst
    local regions = { frame:GetRegions() }
    for i = 1, table.getn(regions) do
        local r = regions[i]
        if r and r.GetObjectType and r:GetObjectType() == "FontString" then
            r:Hide()                    -- "attackbar anchor" / "enemybar anchor"
        end
    end
end

local function styleBar(bar, width)
    if not bar then return end
    local n = bar:GetName()

    bar:SetStatusBarTexture(BAR_TEX)
    bar:SetWidth(width)
    bar:SetHeight(BAR_H)

    -- Zierrahmen und Funke weg: XPerl-Balken sind flach
    local deco = { "Border", "Bordern", "Spark" }
    for i = 1, table.getn(deco) do
        local t = getglobal(n .. deco[i])
        if t then t:Hide() end
    end

    -- dunkler Untergrund, damit der leere Teil des Balkens sichtbar bleibt
    if not bar.xpBg then
        bar.xpBg = bar:CreateTexture(nil, "BACKGROUND")
        bar.xpBg:SetTexture(BAR_TEX)
        bar.xpBg:SetAllPoints(bar)
        bar.xpBg:SetVertexColor(0, 0, 0, 0.5)
    end

    -- Beschriftung wie bei XPerl: Name links, Zeit rechts, klein
    local txt, tmr = getglobal(n .. "Text"), getglobal(n .. "Tmr")
    if txt then
        txt:SetFont("Fonts\\FRIZQT__.TTF", FONT_SZ, "OUTLINE")
        txt:ClearAllPoints(); txt:SetPoint("LEFT", bar, "LEFT", 3, 0)
        txt:SetJustifyH("LEFT")
    end
    if tmr then
        tmr:SetFont("Fonts\\FRIZQT__.TTF", FONT_SZ, "OUTLINE")
        tmr:ClearAllPoints(); tmr:SetPoint("RIGHT", bar, "RIGHT", -3, 0)
        tmr:SetJustifyH("RIGHT")
    end
end

local function layout(container, mh, oh, host, fallback)
    local anchor = host or fallback
    if not container or not anchor then return end

    local width = anchor:GetWidth()
    if not width or width < 40 then width = 195 end

    stripFrame(container)
    styleBar(mh, width)
    styleBar(oh, width)

    container:SetWidth(width)
    container:SetHeight(BAR_H * 2 + BAR_GAP)
    container:ClearAllPoints()
    container:SetPoint("TOP", anchor, "BOTTOM", 0, -PAD)

    if mh then
        mh:ClearAllPoints()
        mh:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
    end
    if oh then
        oh:ClearAllPoints()
        oh:SetPoint("TOPLEFT", container, "TOPLEFT", 0, -(BAR_H + BAR_GAP))
    end
end

local function applyAll()
    layout(Abar_Frame, Abar_Mhr, Abar_Oh, XPerl_Player, PlayerFrame)
    layout(ebar_Frame, ebar_mh,  ebar_oh, XPerl_Target, TargetFrame)
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function()
    applyAll()
    -- AttackBar setzt beim Ein-/Ausblenden eigene Punkte und Rahmen wieder;
    -- deshalb nach jedem Show erneut anwenden.
    local frames = { Abar_Frame, ebar_Frame }
    for i = 1, table.getn(frames) do
        local fr = frames[i]
        if fr and not fr.xpHooked then
            fr.xpHooked = true
            local prev = fr:GetScript("OnShow")
            fr:SetScript("OnShow", function()
                if prev then prev() end
                applyAll()
            end)
        end
    end
end)
