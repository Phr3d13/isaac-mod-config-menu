-- Example: How to use the Menu Selection Tracking API
-- This demonstrates how mods can react to what the user is currently selecting in Mod Config Menu

local MyMod = RegisterMod("Selection Tracking Example", 1)

-- Example 1: Simple callback that prints selection changes
local function onSelectionChange(categoryName, subcategoryName, optionTable)
  if categoryName then
    local message = "User is viewing: " .. categoryName
    if subcategoryName then
      message = message .. " > " .. subcategoryName
    end
    if optionTable and optionTable.Display then
      local displayText = optionTable.Display
      if type(displayText) == "function" then
        displayText = displayText()
      end
      message = message .. " > " .. tostring(displayText)
    end
    Isaac.DebugString("MCM Selection: " .. message)
  else
    Isaac.DebugString("MCM Selection: Menu closed")
  end
end

-- Example 2: Callback that reacts to specific mod settings
local function onMyModSelectionChange(categoryName, subcategoryName, optionTable)
  -- Only react when user is looking at our mod's settings
  if categoryName == "My Example Mod" then
    if optionTable and optionTable.Attribute == "EnableSpecialEffect" then
      -- User is highlighting the "EnableSpecialEffect" setting
      -- Could show a preview of what this effect looks like
      Isaac.DebugString("Showing preview of special effect...")
    elseif optionTable and optionTable.Attribute == "EffectIntensity" then
      -- User is highlighting the intensity slider
      -- Could show different intensity levels in real-time
      local currentValue = optionTable.CurrentSetting()
      Isaac.DebugString("Preview effect intensity: " .. tostring(currentValue))
    end
  end
end

-- Register callbacks when mod loads
if ModConfigMenu and ModConfigMenu.AddSelectionCallback then
  -- Register the general selection tracker
  local callbackId1 = ModConfigMenu.AddSelectionCallback(onSelectionChange)

  -- Register the specific mod tracker
  local callbackId2 = ModConfigMenu.AddSelectionCallback(onMyModSelectionChange)

  Isaac.DebugString("Selection tracking callbacks registered: " .. callbackId1 .. ", " .. callbackId2)
end

-- Example 3: Polling the current selection (alternative approach)
function MyMod:OnRender()
  if ModConfigMenu and ModConfigMenu.IsVisible and ModConfigMenu.GetCurrentSelection then
    local selection = ModConfigMenu.GetCurrentSelection()

    -- Only check every 30 frames to avoid spam
    if Game():GetFrameCount() % 30 == 0 then
      if selection.category == "My Example Mod" and selection.option then
        -- Do something when user is looking at our mod's options
        -- For example, could render additional UI elements or tooltips
      end
    end
  end
end

MyMod:AddCallback(ModCallbacks.MC_POST_RENDER, MyMod.OnRender)

-- Example 4: Query current selection on demand
function MyMod:CheckCurrentMenuSelection()
  if not ModConfigMenu or not ModConfigMenu.GetCurrentSelection then
    return "ModConfigMenu selection API not available"
  end

  local selection = ModConfigMenu.GetCurrentSelection()
  local status = "Menu State: " .. (selection.state or "unknown")

  if selection.category then
    status = status .. "\nCategory: " .. selection.category
  end

  if selection.subcategory then
    status = status .. "\nSubcategory: " .. selection.subcategory
  end

  if selection.option and selection.option.Attribute then
    status = status .. "\nOption: " .. selection.option.Attribute
  end

  return status
end

-- API Usage Summary:
--
-- 1. ModConfigMenu.AddSelectionCallback(callback)
--    - Register a function to be called whenever selection changes
--    - callback(categoryName, subcategoryName, optionTable)
--    - Returns callback ID for removal
--
-- 2. ModConfigMenu.RemoveSelectionCallback(callbackId)
--    - Remove a previously registered callback
--
-- 3. ModConfigMenu.GetCurrentCategory()
--    - Returns name of currently selected category or nil
--
-- 4. ModConfigMenu.GetCurrentSubcategory()
--    - Returns name of currently selected subcategory or nil
--
-- 5. ModConfigMenu.GetCurrentOption()
--    - Returns the currently selected option table or nil
--
-- 6. ModConfigMenu.GetMenuState()
--    - Returns "closed", "categories", "subcategories", "options", or "popup"
--
-- 7. ModConfigMenu.GetCurrentSelection()
--    - Returns table with all selection info: {category, subcategory, option, state}
