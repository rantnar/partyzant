partyzant = partyzant or {
  label = nil,
  gauge = nil,
  room_handler = nil,
  time_handler = nil
}

function partyzant:isForestLocation()
  if not amap.localization.current_short then
    return false
  end
  local forestKeywords = {"las", "puszcza", "bor", "knieja", "lesie", "lasu", "puszczy", "boru"}
  local shortString = amap.localization.current_short
  local lowerLocation = shortString:lower()
  for _, keyword in ipairs(forestKeywords) do
    if string.find(lowerLocation, keyword) then
      return true
    end
  end
  return false
end

function partyzant.timer_func_skrypty_hidden_timer()
  local limit = 15
  local dt = getEpoch() - scripts.ui.hidden_state_epoch
  if dt >= limit then
    stopNamedTimer("arkadia", "hidden_timer")
    partyzant.gauge:setValue(0)
    partyzant.label:echo("&#128373;")
  else
    local val = string.format("%i", ateam.options.countdown and (limit - dt) or dt)
    partyzant.gauge:setValue((limit - dt) / limit * 100)
  end
end

function partyzant:init()
  local footer_info_core = scripts.ui.footer_info_core
  partyzant.label = Geyser.Label:new({
    name = "myLabel",
    x = "100%-125px", y = "100%-230px",
    width = "100px", height = "100px",
    message = "",
    fontSize = 20,
    container = footer_info_core
  })
  partyzant.gauge = Geyser.Gauge:new({
    name = "myGauge",
    x = "100%-125px", y = "100%-130px",
    width = "100px", height = "10px",
    container = footer_info_core
  })


  partyzant.room_handler = scripts.event_register:register_singleton_event_handler(partyzant.room_handler, "amapCompassDrawingDone", function() partyzant:updateLabelMessage() end)
  partyzant.time_handler = scripts.event_register:register_singleton_event_handler(partyzant.time_handler, "gmcp.room.time", function() partyzant:updateLabelBackground() end)

  registerNamedTimer("arkadia", "hidden_timer", 0.1, partyzant.timer_func_skrypty_hidden_timer, true)
  stopNamedTimer("arkadia", "hidden_timer")
end

--room time
function partyzant:updateLabelBackground()
  local imagePath = 'moon.png'
  if gmcp.room.time.daylight == true then
    imagePath = 'sun.png'
  end
  local fullPath = string.format("%s/plugins/partyzant/%s", getMudletHomeDir(), imagePath)
  partyzant.label:setStyleSheet(string.format("border-image: url('%s'); qproperty-alignment: 'AlignRight | AlignVCenter';", fullPath))
end

--room info / compass drawing
function partyzant:updateLabelMessage()
  partyzant.label:echo("")
  local currentLocation = amap.localization.current_short
  if amap.localization.current_short and partyzant:isForestLocation() then
    partyzant.label:echo("🌳")
  end
end

function partyzant:hidden_state(name, seconds)
  self.gauge:setValue(math.max(0, seconds / 15 * 100))
end


partyzant:init()
