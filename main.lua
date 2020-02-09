
function newHandler (a, b)
  local handler = {
    auraPresence = 0,
	spellId = a,
	execution = b
  }
  return handler
end

function handleAuraEvent(myTab)
  local found = 0
  for i = 1, 40 do
    local _, _, _, _, _, _, _, _, _, spellId = UnitAura("player", i)
    if spellId == myTab.spellId then
      found = 1
	  break
    end
  end
  if found == 1 then
    if myTab.auraPresence == 0 then
      myTab.auraPresence = 1
      local playerName = UnitName("player");
      myTab.execution(playerName)
    end
  else
    myTab.auraPresence = 0
  end
end

function newMyTickHandler (a, b)
  local myTickHandler = {maxTicks = a, auraName = b}
  return myTickHandler
end

function handleTick(myTab, timeObj)
  if myTab.maxTicks < 0 then
    timeObj:Cancel()
  elseif myTab.maxTicks == 0 then
    announce(format("%s ENDED", myTab.auraName))
  elseif myTab.maxTicks < 5 then
    announce(format("%s ends in %ds", myTab.auraName, myTab.maxTicks))
  end
  myTab.maxTicks = myTab.maxTicks-1
end

function announce(msg)
	local channel = channelKind()
	if channel == nil then
	  return
	end
	
	SendChatMessage(msg, channel)
end

function lastStand(player)
  announce("LAST STAND ON " .. player)
  local myTab = newMyTickHandler(18, "Last Stand")
  C_Timer.NewTicker(1, function(timerObj) handleTick(myTab, timerObj) end)
end

function shieldWall(player)
  announce("SHIELD WALL ON " .. player)
  local myTab = newMyTickHandler(8, "Shield Wall")
  C_Timer.NewTicker(1, function(timerObj) handleTick(myTab, timerObj) end)
end


--function berserkerRage(player)
--  announce("BERSERKER RAGE ON " .. player)
--  local myTab = newMyTickHandler(8, "Berserker Rage")
--  C_Timer.NewTicker(1, function(timerObj) handleTick(myTab, timerObj) end)
--end


local lastStandHandler = newHandler(12976, lastStand)
local shieldWallHandler = newHandler(871, shieldWall)
--local berserkerRageHandler = newHandler(18499, berserkerRage)

function channelKind()
  if IsInRaid() then
    if InRaidWarningVar and UnitIsGroupLeader("player") then
	  return "RAID_WARNING"
	end
	if InRaidVar == true then
	  return "RAID"
	end
	if InPartyVar == true then
	  return "PARTY"
	end
  elseif IsInGroup() then
	if InPartyVar == true then
	  return "PARTY"
	end
  end
  return nil
end

local eventHandle=function(self, event, arg1, ...)
   if event == "ADDON_LOADED" and arg1 == "RaidAnnouncement" then
	 initUi()
   end
	
   --handleAuraEvent(berserkerRageHandler)
   if LastStandVar == true then
     handleAuraEvent(lastStandHandler)
   end
   if ShieldWallVar == true then
     handleAuraEvent(shieldWallHandler)
   end
end

function initUi()
	local optionsFrame = CreateFrame( "Frame", "optionsFrame", UIParent );
	optionsFrame.name = "RaidAnnouncement";
	InterfaceOptions_AddCategory(optionsFrame);
	
	if InRaidWarningVar == nil then
	  InRaidWarningVar = true
	end
	if InRaidVar == nil then
	  InRaidVar = true
	end
	if InPartyVar == nil then
	  InPartyVar = true
	end
	if LastStandVar == nil then
	  LastStandVar = true
	end
	if ShieldWallVar == nil then
	  ShieldWallVar = true
	end
	local inRaidButton = CreateFrame("CheckButton", "inRaidWarning", optionsFrame, "UICheckButtonTemplate")
	inRaidButton:SetPoint("TOPLEFT",0,0)
	inRaidButton.text:SetText("Announce in /rw")
	inRaidButton:SetChecked(InRaidWarningVar)
	inRaidButton:SetScript("OnClick",function() InRaidWarningVar=not InRaidWarningVar end)
	
	local inRaidButton = CreateFrame("CheckButton", "inRaid", optionsFrame, "UICheckButtonTemplate")
	inRaidButton:SetPoint("TOPLEFT",0,-30)
	inRaidButton.text:SetText("Announce in /ra")
	inRaidButton:SetChecked(InRaidVar)
	inRaidButton:SetScript("OnClick",function() InRaidVar=not InRaidVar end)

	local inPartyButton = CreateFrame("CheckButton", "inParty", optionsFrame, "UICheckButtonTemplate")
	inPartyButton:SetPoint("TOPLEFT",0,-60)
	inPartyButton.text:SetText("Announce in /p")
	inPartyButton:SetChecked(InPartyVar)
	inPartyButton:SetScript("OnClick",function() InPartyVar=not InPartyVar end)	
	
	local lastStandButton = CreateFrame("CheckButton", "LastStand", optionsFrame, "UICheckButtonTemplate")
	lastStandButton:SetPoint("TOPLEFT",0,-120)
	lastStandButton.text:SetText("Last Stand")
	lastStandButton:SetChecked(LastStandVar)
	lastStandButton:SetScript("OnClick",function() LastStandVar=not LastStandVar end)	
	
	local shieldWallButton = CreateFrame("CheckButton", "shieldWall", optionsFrame, "UICheckButtonTemplate")
	shieldWallButton:SetPoint("TOPLEFT",0,-150)
	shieldWallButton.text:SetText("Shield Wall")
	shieldWallButton:SetChecked(ShieldWallVar)
	shieldWallButton:SetScript("OnClick",function() ShieldWallVar=not ShieldWallVar end)	
end

local frame = CreateFrame("Frame")
frame:RegisterUnitEvent ("UNIT_AURA", "player")
frame:RegisterEvent("ADDON_LOADED");
frame:SetScript("OnEvent", eventHandle)