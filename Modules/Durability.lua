local addon, ns = ... 
local C, F, G, L = unpack(ns)
if not C.Durability then return end

local format = string.format
local floor = math.floor
local sort = table.sort

--=================================================--
---------------    [[ Elements ]]     ---------------
--=================================================--

--[[ Create elements ]]--
local Stat = CreateFrame("Frame", G.addon.."Dura", UIParent)
	Stat:SetHitRectInsets(-5, -5, -10, -10)
	Stat:SetFrameStrata("BACKGROUND")

--[[ Create text ]]--
local Text  = Stat:CreateFontString(nil, "OVERLAY")
	Text:SetFont(G.Fonts, G.FontSize, G.FontFlag)
	Text:SetPoint(unpack(C.DurabilityPoint))
	Stat:SetAllPoints(Text)

--==================================================--
---------------    [[ Functions ]]     ---------------
--==================================================--

local function gradientColor(perc)
	perc = perc > 1 and 1 or perc < 0 and 0 or perc -- Stay between 0-1
		
	local seg, relperc = math.modf(perc*2)
	local r1, g1, b1, r2, g2, b2 = select(seg*3+1, 1, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0) -- R -> Y -> G
	local r, g, b = r1+(r2-r1)*relperc, g1+(g2-g1)*relperc, b1+(b2-b1)*relperc
	
	return format("|cff%02x%02x%02x", r*255, g*255, b*255), r, g, b
end

-- slots
local localSlots = {
	[1] = {1, INVTYPE_HEAD, 1000},
	[2] = {3, INVTYPE_SHOULDER, 1000},
	[3] = {5, INVTYPE_CHEST, 1000},
	[4] = {6, INVTYPE_WAIST, 1000},
	[5] = {9, INVTYPE_WRIST, 1000},
	[6] = {10, INVTYPE_HAND, 1000},
	[7] = {7, INVTYPE_LEGS, 1000},
	[8] = {8, INVTYPE_FEET, 1000},
	[9] = {16, INVTYPE_WEAPONMAINHAND, 1000},
	[10] = {17, INVTYPE_WEAPONOFFHAND, 1000},
	[11] = {18, INVTYPE_RANGED, 1000}
}
	
--[[ Sort slots ]]--
local function sortSlots(a, b)
	if a and b then
		return (a[3] == b[3] and a[1] < b[1]) or (a[3] < b[3])
	end
end

--[[ Custom api to get durability ]]--
local function getItemDurability()
	local numSlots = 0
	
	for i = 1, 10 do
		localSlots[i][3] = 1000
		
		local index = localSlots[i][1]
		
		if GetInventoryItemLink("player", index) then
			local current, max = GetInventoryItemDurability(index)
			
			if current then
				localSlots[i][3] = current/max
				numSlots = numSlots + 1
			end
		end
	end
	sort(localSlots, sortSlots)

	return numSlots
end

--================================================--
---------------    [[ Updates ]]     ---------------
--================================================--

--[[ Data text update ]]--
local function OnEvent(self)
	if diminfo.AutoRepair == nil then
		diminfo.AutoRepair = true
	end
	
	local numSlots = getItemDurability()
	local dcolor = gradientColor((floor(localSlots[1][3]*100)/100))
	
	if numSlots > 0 then
		if C.ClassColor then
			Text:SetText(F.Hex(G.Ccolors)..L.Dura.." |r"..dcolor..math.floor(localSlots[1][3]*100).."|r%")
		else
			Text:SetText(L.Dura..dcolor..math.floor(localSlots[1][3]*100).."|r%")
		end
	else
		Text:SetText(C.ClassColor and F.Hex(G.Ccolors)..L.None or L.None)
	end
end

--[[ Tooltip update ]]--
local function OnEnter(self)
	
	-- title
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -10)
	GameTooltip:ClearLines()
	local p1 = select(3, GetTalentTabInfo(1))
	local p2 = select(3, GetTalentTabInfo(2))
	local p3 = select(3, GetTalentTabInfo(3))
	GameTooltip:AddDoubleLine(TALENT, p1.."/"..p2.."/"..p3, 0, .6, 1, 0, .6, 1)
	GameTooltip:AddLine(" ")
	
	-- slot item list
	for i = 1, 11 do
		if localSlots[i][3] ~= 1000 then
			local slot = localSlots[i][1]
			local green = localSlots[i][3]*2
			local red = 1 - green

			GameTooltip:AddDoubleLine(F.addIcon(GetInventoryItemTexture("player", slot), 14, 4, 46)..localSlots[i][2], floor(localSlots[i][3]*100).."%", 1, 1, 1, red+1, green, 0)
		end
	end
	
	-- otpions
	GameTooltip:AddDoubleLine(" ", G.Line)
	GameTooltip:AddDoubleLine(" ", G.OptionColor..CHARACTER_INFO..G.LeftButton)
	GameTooltip:AddDoubleLine(" ", G.OptionColor..L.AutoRepair..(diminfo.AutoRepair and "|cff55ff55"..ENABLE or "|cffff5555"..DISABLE)..G.RightButton)
	
	GameTooltip:Show()
end

--================================================--
---------------    [[ Scripts ]]     ---------------
--================================================--
	
	--[[ Tooltip ]]--
	Stat:SetScript("OnEnter", OnEnter)
	Stat:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	
	--[[ Options ]]--
	Stat:SetScript("OnMouseDown", function(self, button)
		if button == "RightButton" then
			diminfo.AutoRepair = not diminfo.AutoRepair
			self:GetScript("OnEnter")(self)
		else
			if InCombatLockdown() then
				UIErrorsFrame:AddMessage(G.ErrColor..ERR_NOT_IN_COMBAT)
				return
			end
			ToggleCharacter("PaperDollFrame")
		end
	end)
	
	--[[ Data text ]]--
	Stat:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
	Stat:RegisterEvent("MERCHANT_SHOW")
	Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
	Stat:SetScript("OnEvent", OnEvent)

--====================================================--
---------------    [[ Auto repair ]]     ---------------
--====================================================--

local RepairGear = CreateFrame("Frame")
	RepairGear:RegisterEvent("MERCHANT_SHOW")
	RepairGear:SetScript("OnEvent", function()
		if (diminfo.AutoRepair == true and CanMerchantRepair()) then
			local money = GetMoney()
			local cost, canRepair = GetRepairAllCost()
			
			-- 可以修裝而且花費大於零
			if canRepair and cost > 0 then
				if IsInGuild() then
					local guildMoney = GetGuildBankWithdrawMoney()
					
					-- 可提領金額大於公會餘額
					if guildMoney > GetGuildBankMoney() then
						guildMoney = GetGuildBankMoney()
					end
					
					if guildMoney >= cost and CanGuildBankRepair() then
						RepairAllItems(1)
						print(format("|cff99CCFF"..GUILDCONTROL_OPTION15.."|r%s", GetMoneyString(cost)))
						return
					elseif guildMoney == 0 and IsGuildLeader() then
						RepairAllItems(1)
						print(format("|cff99CCFF"..GUILDCONTROL_OPTION15.."|r%s", GetMoneyString(cost)))
						return
					end
				end
				
				if money > cost then
					RepairAllItems()
					print(format("|cff99CCFF"..REPAIR_COST.."|r%s", GetMoneyString(cost)))
				else
					print("|cff99CCFF"..ERR_NOT_ENOUGH_MONEY.."|r")
				end
			end
		end
	end)