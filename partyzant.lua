local label, gauge

-- Sprawdza, czy lokalizacja zawiera słowa związane z lasem
local function isForestLocation(location)
  local forestKeywords = {"las", "puszcza", "bor", "knieja"}
  local lowerLocation = location:lower()
  for _, keyword in ipairs(forestKeywords) do
    if string.find(lowerLocation, keyword) then return true end
  end
  return false
end

-- Tworzy nowy label
local function createLabel()
  print("Tworzenie labela")
  label = Geyser.Label:new({
    name = "myLabel", x = "-13%", y = "75%", width = "10%", height = "10%", message = "", fontSize = 20
  })
end

-- Tworzy nowy wskaźnik
local function createGauge()
  print("Tworzenie gauge")
  gauge = Geyser.Gauge:new({
    name = "myGauge", x = "-13%", y = "85%", width = "10%", height = "1%"
  })
end

-- Aktualizuje tło labela
local function updateLabelBackground(isDaylight)
  print("Aktualizacja tła labela")
  local imagePath = isDaylight and 'sun.png' or 'moon.png'
  local fullPath = string.format("%s/plugins/partyzant/%s", getMudletHomeDir(), imagePath)
  label:setStyleSheet(string.format("border-image: url('%s'); qproperty-alignment: 'AlignRight | AlignVCenter';", fullPath))
end

-- Aktualizuje wiadomość labela na podstawie nowej lokalizacji
local function updateLabelMessage()
  print("Aktualizacja wiadomości labela")
  label:echo("")
  local currentLocation = amap.localization.current_short
  print("Bieżąca lokalizacja: " .. (currentLocation or "brak"))
  if isForestLocation(currentLocation) then
    label:echo("🌳")
  end
end

-- Aktualizuje UI na podstawie nowej lokalizacji
local function updateUI()
  print("Aktualizacja UI")
  if not label then createLabel() end
  if not gauge then createGauge() end
  updateLabelMessage()
  local isDaylight = gmcp.room.time.daylight
  scripts.ui:info_daylight_update(isDaylight)
  updateLabelBackground(isDaylight)
end

-- Obsługuje stan ukrycia
function hidden_state(name, seconds)
  gauge:setValue(math.max(0, seconds / 15 * 100))
end

function timer_func_skrypty_hidden_timer()
  local limit = 15
  local dt = getEpoch() - scripts.ui.hidden_state_epoch
  if dt >= limit then
    stopNamedTimer("arkadia", "hidden_timer")
    scripts.ui.states_window_nav_states["hidden_state"] = ""
    scripts.ui:info_hidden_update("")
    gauge:setValue(0)
  else
    local val = string.format("%i", ateam.options.countdown and (limit - dt) or dt)
    scripts.ui.states_window_nav_states["hidden_state"] = "<red>" .. val
    scripts.ui:info_hidden_update(val)
    gauge:setValue((limit - dt) / limit * 100)
  end
  ateam:print_status()
  scripts.ui:navbar_updates("hidden_state")
  raiseEvent("hidden_state", dt)
end

if scripts.event_handlers["skrypty/ui/gmcp_handlers/hidden_state.hidden_state.hidden_state"] then
  killAnonymousEventHandler(scripts.event_handlers["skrypty/ui/gmcp_handlers/hidden_state.hidden_state.hidden_state"])
end

scripts.ui.hidden_state_epoch = 0
scripts.event_handlers["skrypty/ui/gmcp_handlers/hidden_state.hidden_state.hidden_state"] = registerAnonymousEventHandler("hidden_state", hidden_state)

registerNamedTimer("arkadia", "hidden_timer", 0.1, timer_func_skrypty_hidden_timer, true)
stopNamedTimer("arkadia", "hidden_timer")

-- Inicjalizacja UI
print("Inicjalizacja UI")
updateUI()

-- Rejestracja event handlera dla zmiany lokacji
print("Rejestracja event handlera dla zmiany lokacji")
scripts.event_register:register_event_handler("gmcp.room.info", function()
  print("Event handler: gmcp.room.info")
  tempTimer(0.1, updateUI)
end)

-- Rejestracja event handlera dla zmiany pory dnia
print("Rejestracja event handlera dla zmiany pory dnia")
scripts.event_register:register_event_handler("gmcp.room.time", function()
  print("Event handler: gmcp.room.time")
  local isDaylight = gmcp.room.time.daylight
  scripts.ui:info_daylight_update(isDaylight)
  updateLabelBackground(isDaylight)
end)