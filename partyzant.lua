partyzant = partyzant or {
  background = nil,
  gauge = nil,
  states = nil,
  room_handler = nil,
  time_handler = nil
}

function partyzant:isForestLocation()
  if not amap.localization.current_short then
    return false
  end
  local forestKeywords = {"las", "puszcza", "bor", "knieja", "lesie", "lasu", "puszczy", "boru", "tajdze", "lesnej"}
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
    partyzant:updateLabelMessage()
  else
    local val = string.format("%i", ateam.options.countdown and (limit - dt) or dt)
    partyzant.gauge:setValue((limit - dt) / limit * 100)
  end
end

function partyzant:init()
  local footer_info_core = scripts.ui.footer_info_core
  partyzant.background = Geyser.Label:new({
    name = "bg",
    x = "100%-65px", y = "0",
    width = "50px", height = "50px",
    message = "",
    fontSize = 20,
    container = footer_info_core
  })
  
  partyzant.gauge = Geyser.Gauge:new({
    name = "myGauge",
    x = "0", y = "50px",
    width = "50px", height = "5px",
    
  }, partyzant.background)
  
  partyzant.states = Geyser.Label:new({
    name = "st",
    x = "0", y = "5px",
    width = "50px", height = "20px",
    message = "",
    fontSize = 11,
  },partyzant.gauge)

  partyzant.states:setStyleSheet("background-color: transparent;")


  partyzant.room_handler = scripts.event_register:register_singleton_event_handler(partyzant.room_handler, "amapCompassDrawingDone", function() partyzant:updateLabelMessage() end)
  partyzant.gmcp_handler = scripts.event_register:register_singleton_event_handler(partyzant.gmcp_handler, "gmcp_parsing_finished", function() partyzant:updateLabelMessage() end)
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
  partyzant.background:setStyleSheet(string.format("border-image: url('%s'); qproperty-alignment: 'AlignRight | AlignVCenter';", fullPath))
end

--room info / compass drawing
function partyzant:updateLabelMessage()
  local myString = ""
  local currentLocation = amap.localization.current_short
  if amap.localization.current_short and partyzant:isForestLocation() then
    myString =  "🌳"
  end
  if ateam.objs[ateam.my_id].hidden == true then
     myString = myString .. "🕵"
  end
  
  partyzant.states:echo(myString)
end

function partyzant:hidden_state(name, seconds)
  self.gauge:setValue(math.max(0, seconds / 15 * 100))
end


partyzant:init()
