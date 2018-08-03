local addon, ns = ...local cfg = ns.cfglocal panel = CreateFrame("Frame", nil, UIParent)if cfg.Positions == true then  	-- make addon frame anchor-able	local Stat = CreateFrame("Frame", "diminfo_pos")	Stat:EnableMouse(true)	Stat:SetFrameStrata("BACKGROUND")	Stat:SetFrameLevel(3)    	-- setup text	local Text  = panel:CreateFontString(nil, "OVERLAY")	Text:SetFont(unpack(cfg.Fonts))	Text:SetPoint(unpack(cfg.PositionsPoint))	Stat:SetAllPoints(Text)	-- zone text color	local colorT = {	sanctuary = {SANCTUARY_TERRITORY, {0.41,0.8,0.94}};	arena = {FREE_FOR_ALL_TERRITORY, {1,0.1,0.1}};	friendly = {FACTION_CONTROLLED_TERRITORY, {0.1,1,0.1}};	hostile = {FACTION_CONTROLLED_TERRITORY, {1,0.1,0.1}};	contested = {CONTESTED_TERRITORY, {1,0.7,0}};	combat = {COMBAT_ZONE, {1,0.1,0.1}};	neutral = {format(FACTION_CONTROLLED_TERRITORY,FACTION_STANDING_LABEL4), {1,0.93,0.76}}	}	-- position	--[[local coordX, coordY = 0, 0	local function formatCoords()		return format("%.1f, %.1f", coordX*100, coordY*100)	end]]--	-- tooltip	local function OnEvent()		subzone, zone, pvp = GetSubZoneText(), GetZoneText(), {GetZonePVPInfo()}		if not pvp[1] then pvp[1] = "neutral" end		local r,g,b = unpack(colorT[pvp[1]][2])		Text:SetText((subzone ~= "") and subzone or zone)		Text:SetTextColor(r,g,b)	end	Stat:RegisterEvent("ZONE_CHANGED")	Stat:RegisterEvent("ZONE_CHANGED_INDOORS")	Stat:RegisterEvent("ZONE_CHANGED_NEW_AREA")	Stat:RegisterEvent("PLAYER_ENTERING_WORLD")	Stat:SetScript("OnEvent",OnEvent)		-- setup	Stat:SetScript("OnEnter",function(self)		self:SetAllPoints(Text)		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 0, -10)		GameTooltip:ClearAllPoints()		GameTooltip:SetPoint("BOTTOM", self, "BOTTOM", 0, 1)		GameTooltip:ClearLines()		--[[if not IsInInstance() then			GameTooltip:AddLine(format("%s |cffffffff(%s)",zone,formatCoords()),0,.8,1,1,1,1)		else			GameTooltip:AddLine(zone,0,.8,1,1,1,1)		end]]--		GameTooltip:AddLine(zone,0,.8,1,1,1,1)		if pvp[1] and not IsInInstance() then			local r,g,b = unpack(colorT[pvp[1]][2])			if subzone and subzone ~= zone then				GameTooltip:AddLine(subzone,r,g,b)			end			GameTooltip:AddLine(format(colorT[pvp[1]][1],pvp[3] or ""),r,g,b)		end		GameTooltip:Show()	end)	Stat:SetScript("OnLeave",function() GameTooltip:Hide() end)	Stat:SetScript("OnMouseUp", function(_,btn)		if btn == "LeftButton" then			ToggleFrame(WorldMapFrame)		else			--ChatFrame_OpenChat(format("%s%s (%s)",infoL["My Position"], zone, formatCoords()), chatFrame)			ChatFrame_OpenChat(infoL["My Position"]..zone, chatFrame)		end	end)	--[[Stat:SetScript("OnUpdate",function()		coordX, coordY = GetPlayerMapPosition("player")	end)]]--end