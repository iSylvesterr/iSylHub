local Games = loadstring(game:HttpGet("https://raw.githubusercontent.com/iSylvesterr/iSylHub/refs/heads/main/isyl.lua"))()

local URL = Games[game.PlaceId]

if URL then
  loadstring(game:HttpGet(URL))()
end
