--todo
--add deathwish

function newHandler (inSpellId, inExecution)
  local handler = {
    auraPresence = 0,
	spellId = inSpellId,
	execution = inExecution
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
      myTab.execution(playerName, myTab)
    end
  else
    myTab.auraPresence = 0
  end
end

function handleTick(tickState, myTab, timeObj)
  if tickState.maxTicks < 0 then
    timeObj:Cancel()
  else
    if myTab.auraPresence == 0 then
      tickState.maxTicks = 0
    end
    if tickState.maxTicks == 0 then
      announce(format("%s ENDED", tickState.auraName))
    elseif tickState.maxTicks <= tickState.countDown then
      announce(format("%s ends in %ds", tickState.auraName, tickState.maxTicks))
    end
  end
  tickState.maxTicks = tickState.maxTicks-1
end

function announce(msg)
	local channel = channelKind()
	if channel == nil then
	  return
	end
	
	SendChatMessage(msg, channel)
	--print(msg)
end

function lastStand(player, myTab)
  announce("LAST STAND ON " .. player)
  local tickState = {maxTicks = 18, auraName = "Last Stand", countDown = LastStandCountDownVar}
  C_Timer.NewTicker(1, function(timerObj) handleTick(tickState, myTab, timerObj) end)
end

function shieldWall(player, myTab)
  announce("SHIELD WALL ON " .. player)
  local tickState = {maxTicks = 8, auraName = "Shield Wall", countDown = ShieldWallCountDownVar}
  C_Timer.NewTicker(1, function(timerObj) handleTick(tickState, myTab, timerObj) end)
end

--[[
function berserkerRage(player, myTab)
  announce("BERSERKER RAGE ON " .. player)
  local tickState = {maxTicks = 8, auraName = "Berserker Rage", countDown = LastStandCountDownVar}
  C_Timer.NewTicker(1, function(timerObj) handleTick(tickState, myTab, timerObj) end)
end
--]]


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

local sliderLabelUpdate = function(slider)
  local newValue = slider:GetValue()
  text = format("%d seconds", newValue)
  if (newValue == 0) then
    text = "Off"
  end
  getglobal(slider:GetName() .. 'Text'):SetText(text)
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
	if LastStandCountDownVar == nil then
	  LastStandCountDownVar = 2
	end
	if ShieldWallCountDownVar == nil then
	  ShieldWallCountDownVar = 2
	end
	local inRaidButton = CreateFrame("CheckButton", "InRaidWarningButton", optionsFrame, "UICheckButtonTemplate")
	inRaidButton:SetPoint("TOPLEFT",0,0)
	inRaidButton.text:SetText("Announce in /rw")
	inRaidButton:SetChecked(InRaidWarningVar)
	inRaidButton:SetScript("OnClick",function() InRaidWarningVar=not InRaidWarningVar end)
	
	local inRaidButton = CreateFrame("CheckButton", "InRaidButton", optionsFrame, "UICheckButtonTemplate")
	inRaidButton:SetPoint("TOPLEFT",0,-30)
	inRaidButton.text:SetText("Announce in /ra")
	inRaidButton:SetChecked(InRaidVar)
	inRaidButton:SetScript("OnClick",function() InRaidVar=not InRaidVar end)

	local inPartyButton = CreateFrame("CheckButton", "InPartyButton", optionsFrame, "UICheckButtonTemplate")
	inPartyButton:SetPoint("TOPLEFT",0,-60)
	inPartyButton.text:SetText("Announce in /p")
	inPartyButton:SetChecked(InPartyVar)
	inPartyButton:SetScript("OnClick",function() InPartyVar=not InPartyVar end)	
	
	local lastStandButton = CreateFrame("CheckButton", "LastStandButton", optionsFrame, "UICheckButtonTemplate")
	lastStandButton:SetPoint("TOPLEFT",0,-120)
	lastStandButton.text:SetText("Last Stand")
	lastStandButton:SetChecked(LastStandVar)
	lastStandButton:SetScript("OnClick",function() LastStandVar=not LastStandVar end)	
	
	local shieldWallButton = CreateFrame("CheckButton", "ShieldWallButton", optionsFrame, "UICheckButtonTemplate")
	shieldWallButton:SetPoint("TOPLEFT",0,-150)
	shieldWallButton.text:SetText("Shield Wall")
	shieldWallButton:SetChecked(ShieldWallVar)
	shieldWallButton:SetScript("OnClick",function() ShieldWallVar=not ShieldWallVar end)	
	
	local countDownSliderLastStand = CreateFrame("Slider", "CountDownSliderLastStand", optionsFrame, "OptionsSliderTemplate")
	countDownSliderLastStand:SetOrientation('HORIZONTAL')
	countDownSliderLastStand:SetPoint("TOPLEFT",150,-128)
	countDownSliderLastStand:SetMinMaxValues(0, 4)
	
	countDownSliderLastStand:SetValueStep(1)
	countDownSliderLastStand:SetObeyStepOnDrag(true)
	getglobal(countDownSliderLastStand:GetName() .. 'Low'):SetText(nil)
	getglobal(countDownSliderLastStand:GetName() .. 'High'):SetText(nil)
    sliderLabelUpdate(countDownSliderLastStand)
	countDownSliderLastStand:SetScript("OnValueChanged", function(self, newvalue)
		sliderLabelUpdate(countDownSliderLastStand)
		LastStandCountDownVar = newvalue
    end)
	countDownSliderLastStand:SetValue(LastStandCountDownVar)
	
	local countDownSliderShieldWall = CreateFrame("Slider", "CountDownSliderShieldWall", optionsFrame, "OptionsSliderTemplate")
	countDownSliderShieldWall:SetOrientation('HORIZONTAL')
	countDownSliderShieldWall:SetPoint("TOPLEFT",150,-158)
	countDownSliderShieldWall:SetMinMaxValues(0, 4)
	
	countDownSliderShieldWall:SetValueStep(1)
	countDownSliderShieldWall:SetObeyStepOnDrag(true)
	getglobal(countDownSliderShieldWall:GetName() .. 'Low'):SetText(nil)
	getglobal(countDownSliderShieldWall:GetName() .. 'High'):SetText(nil)
    sliderLabelUpdate(countDownSliderShieldWall)
	countDownSliderShieldWall:SetScript("OnValueChanged", function(self, newvalue)
		sliderLabelUpdate(countDownSliderShieldWall)
		ShieldWallCountDownVar = newvalue
    end)
    countDownSliderShieldWall:SetValue(ShieldWallCountDownVar)
	  
end


	 
local frame = CreateFrame("Frame")
frame:RegisterUnitEvent ("UNIT_AURA", "player")
frame:RegisterEvent("ADDON_LOADED");
frame:SetScript("OnEvent", eventHandle)