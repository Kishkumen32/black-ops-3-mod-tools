
local function ClearBubblegumPackEvt(HudObj, EventObj)
	HudObj.BubbleGumPackInGame:close()
end

InventoryWidget:registerEventHandler("menu_loaded", ClearBubbleGumPackEvt)