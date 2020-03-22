local addon, ns = ... 
local C, F, G, DB = unpack(ns)

F.Hex = function(r, g, b)
	-- 未定義則白色
	if not r then return "|cffFFFFFF" end
	
	if type(r) == "table" then
		if(r.r) then
			r, g, b = r.r, r.g, r.b
		else
			r, g, b = unpack(r)
		end
	end
	
	return ("|cff%02x%02x%02x"):format(r * 255, g * 255, b * 255)
end

-- 職業列表轉換
F.ClassList = {}
for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do
	F.ClassList[v] = k
end

-- 多重條件
F.Multicheck = function(check, ...)
	for i = 1, select("#", ...) do
		if check == select(i, ...) then
			return true
		end
	end
	return false
end

-- 材質，尺寸，切邊1，切邊2
F.addIcon = function(texture, size, cut1, cut2)
	texture = texture and "|T"..texture..":"..size..":"..size..":0:0:50:50:"..cut1..":"..cut2..":"..cut1..":"..cut2.."|t" or ""
	return texture
end

F.Wrap = function(str, limit, indent, indent1)
  indent = indent or ""
  indent1 = indent1 or indent
  limit = limit or 69
  local here = 1-#indent1
  
  return indent1..str:gsub("(%s+)()(%S+)()",
	function(sp, st, word, fi)
		if fi-here > limit then
			  here = st - #indent
			  return "\n"..indent..word
		end
	end)
end

-- 創建框架
F.CreatePanel = function(anchor, parent, x, y, w, h, size)
	local panel = CreateFrame("Frame", nil, parent)
	local framelvl = parent:GetFrameLevel()
	
    panel:SetWidth(w)
	panel:SetHeight(h)
	panel:ClearAllPoints()
	panel:SetPoint(anchor, parent, x, y)
	panel:SetFrameStrata("BACKGROUND")
	panel:SetFrameLevel(framelvl == 0 and 0 or framelvl-1)
	panel:SetBackdrop({
		bgFile = G.Tex,
		edgeFile = G.Tex, edgeSize = 1,
	})
	panel:SetBackdropColor( .1, .1, .1, .6)
	panel:SetBackdropBorderColor( .1, .1, .1, .6)

	sd = CreateFrame("Frame", nil, panel)
	sd:SetPoint("TOPLEFT", -size, size)
	sd:SetPoint("BOTTOMRIGHT", size, -size)
	sd:SetFrameStrata(panel:GetFrameStrata())
	sd:SetFrameLevel(framelvl == 0 and 0 or framelvl-1)
	sd:SetBackdrop({
		edgeFile = G.Glow,
		edgeSize = size,
	})
	sd:SetBackdropBorderColor(0, 0, 0)

	return panel
end


	F.CreatePanel(unpack(C.Panel1))
	if C.Panel2 then F.CreatePanel(unpack(C.Panel2)) end
	if C.Panel3 then F.CreatePanel(unpack(C.Panel3)) end
	if C.Panel4 then F.CreatePanel(unpack(C.Panel4)) end
	if C.Panel5 then F.CreatePanel(unpack(C.Panel5)) end


G.LeftButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:230:307|t "
G.RightButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:333:411|t "
G.MiddleButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:127:204|t "
	
G.AFK = "|T"..FRIENDS_TEXTURE_AFK..":14:14:0:0:16:16:1:15:1:15|t"
G.DND = "|T"..FRIENDS_TEXTURE_DND..":14:14:0:0:16:16:1:15:1:15|t"
