-- =========================
-- iSylHub FluentPlus + Key System (Black-Red Fluent + HWID Kick + Auto-global + Fixed Fade)
-- Full combined loader: UI preserved, sets globals for third-party loaders, supports direct global key usage
-- =========================

-- =========================
-- CONFIG
-- =========================
local KEY_CHECK_URL    = "https://victor-lineable-detersively.ngrok-free.dev/check"
local GET_KEY_URL      = "https://discord.gg/9B3sxTxD2E"
local MAIN_SCRIPT_URL  = "https://pastebin.com/raw/GNKjZEMq"
local CACHE_PATH       = "iSyl_key_cache.txt"
local AUTO_VERIFY      = true
local USE_CACHE_OFFLINE = true

-- =========================
-- SERVICES
-- =========================
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local Analytics = game:GetService("RbxAnalyticsService")
local Player = Players.LocalPlayer

-- =========================
-- UTIL: safe http get
-- =========================
local function safe_get(url)
	local ok, res = pcall(function()
		if syn and syn.request then
			return syn.request({Url = url, Method = "GET"}).Body
		elseif request then
			return request({Url = url, Method = "GET"}).Body
		elseif http and http.request then
			return http.request({Url = url, Method = "GET"}).Body
		elseif game.HttpGet then
			return game:HttpGet(url)
		else
			return nil
		end
	end)
	return ok and res or nil
end

-- =========================
-- CACHE HELPERS
-- =========================
local function save_cache(key)
	if writefile then pcall(function() writefile(CACHE_PATH, key) end) end
end
local function load_cache()
	if readfile and isfile and isfile(CACHE_PATH) then
		local ok, res = pcall(function() return readfile(CACHE_PATH) end)
		if ok and res and res ~= "" then return res:gsub("%s+","") end
	end
	return nil
end

-- =========================
-- HWID RESET DETECTION
-- =========================
local function is_hwid_reset_response(json)
	if type(json) ~= "table" then return false end
	if json.reset_hwid == true or json.hwid_reset == true then return true end
	if json.reset and tostring(json.reset):lower():find("hwid") then return true end
	if json.msg and tostring(json.msg):upper():find("HWID") and tostring(json.msg):upper():find("RESET") then return true end
	return false
end

local function do_hwid_kick()
	pcall(function()
		Player:Kick("anda telah di keluarkan oleh moderator pesan : HWID HAS BEEN RESET")
	end)
end

-- =========================
-- LOAD MAIN SCRIPT (safe)
-- =========================
local function load_main_script()
	local body = safe_get(MAIN_SCRIPT_URL)
	if not body then
		warn("[iSylHub] Gagal ambil main script.")
		return
	end
	local fn, err = (loadstring and loadstring(body)) or load(body)
	if not fn then
		warn("[iSylHub] Gagal compile main script:", err)
		return
	end
	local ok, runErr = pcall(fn)
	if not ok then
		warn("[iSylHub] Error saat menjalankan main script:", runErr)
	else
		print("[iSylHub] Main script executed successfully ✅")
	end
end

-- =========================
-- on_key_valid: set globals, fade UI, load main
-- =========================
local function set_globals_for_main(key)
	pcall(function()
		if getgenv then
			-- common names to maximize compatibility
			getgenv().script_key = key
			getgenv().key = key
			getgenv().Key = key
			getgenv().KEY = key
			getgenv().auth_key = key
			getgenv().user_key = key
			getgenv().iSyl_key = key
		end
		_G.script_key = key
		_G.key = key
		_G.Key = key
		_G.KEY = key
	end)
end

local function on_key_valid(key)
	-- 1) Save cache
	save_cache(key)

	-- 2) Set globals so external/third-party loaders detect the key immediately
	set_globals_for_main(key)

	-- 3) Fade-out UI then destroy (safe)
	if screen and screen.Parent and frame then
		pcall(function()
			-- fade frame background
			local ok, tweenErr = pcall(function()
				TweenService:Create(frame, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
			end)
			-- fade text elements
			for _, v in pairs(frame:GetDescendants()) do
				if v:IsA("TextLabel") or v:IsA("TextBox") or v:IsA("TextButton") then
					pcall(function()
						TweenService:Create(v, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
					end)
				elseif v:IsA("ImageLabel") or v:IsA("ImageButton") then
					pcall(function()
						TweenService:Create(v, TweenInfo.new(0.3), {ImageTransparency = 1}):Play()
					end)
				elseif v:IsA("Frame") and v ~= frame then
					pcall(function()
						TweenService:Create(v, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
					end)
				end
			end
			task.wait(0.45)
			if screen and screen.Parent then
				pcall(function() screen:Destroy() end)
			end
		end)
	end

	-- 4) small delay to ensure the environment is clean, then load main script
	task.delay(0.12, function()
		load_main_script()
	end)
end

-- =========================
-- AUTO-LOGIN (cache / existing globals)
-- =========================
-- If user already set global key before running this loader,
-- detect and auto-validate using that key (skip UI).
local function find_existing_global_key()
	local candidates = {}
	pcall(function()
		if getgenv then
			for _, name in ipairs({"script_key","key","Key","KEY","auth_key","user_key","iSyl_key"}) do
				local ok, val = pcall(function() return getgenv()[name] end)
				if ok and type(val) == "string" and val:match("%S") then
					table.insert(candidates, val)
				end
			end
		end
		-- also check _G and raw globals (some users set 'script_key' as a global var)
		for _, name in ipairs({"script_key","key","Key","KEY"}) do
			local ok, val = pcall(function() return _G[name] end)
			if ok and type(val) == "string" and val:match("%S") then
				table.insert(candidates, val)
			end
		end
		-- check global direct variable (less common in this env, but try)
		local ok, val = pcall(function() return script_key end)
		if ok and type(val) == "string" and val:match("%S") then table.insert(candidates, val) end
	end)
	return candidates[1] -- return first found
end

-- try: 1) global set by user, 2) cached key
local pre_existing_key = find_existing_global_key()
if pre_existing_key then
	-- found a global key: trust it, set globals (normalize names) and load main script directly
	set_globals_for_main(pre_existing_key)
	-- load main script right away (do not show UI)
	task.defer(function() load_main_script() end)
	-- stop here, do not create UI
	return
end

local cachedKey = load_cache()
if cachedKey then
	if AUTO_VERIFY then
		local hwid = Analytics:GetClientId()
		local url = string.format("%s?key=%s&hwid=%s", KEY_CHECK_URL, HttpService:UrlEncode(cachedKey), HttpService:UrlEncode(hwid))
		local res = safe_get(url)
		if res then
			local ok,json = pcall(function() return HttpService:JSONDecode(res) end)
			if ok and type(json)=="table" then
				if is_hwid_reset_response(json) then do_hwid_kick() return end
				if json.ok then on_key_valid(cachedKey) return
				else if isfile and delfile then pcall(function() delfile(CACHE_PATH) end) end end
			end
		elseif USE_CACHE_OFFLINE then on_key_valid(cachedKey) return end
	else on_key_valid(cachedKey) return end
end

-- =========================
-- BUILD FLUENT BLACK-RED UI (DESIGN PRESERVED)
-- =========================
pcall(function()
	local old = Player:FindFirstChild("PlayerGui") and Player.PlayerGui:FindFirstChild("iSylKeyUI")
	if old then old:Destroy() end
end)

screen = Instance.new("ScreenGui")
screen.Name = "iSylKeyUI"
screen.ResetOnSpawn = false
screen.Parent = Player:WaitForChild("PlayerGui")

frame = Instance.new("Frame")
frame.Size = UDim2.fromScale(0.4,0.28)
frame.Position = UDim2.fromScale(0.5,0.5)
frame.AnchorPoint = Vector2.new(0.5,0.5)
frame.BackgroundColor3 = Color3.fromRGB(15,15,15)
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
frame.Parent = screen
frame.Active = true
frame.Draggable = true

Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)
local stroke = Instance.new("UIStroke", frame)
stroke.Thickness = 1.3
stroke.Color = Color3.fromRGB(255,50,50)
stroke.Transparency = 0.2
local gradient = Instance.new("UIGradient", frame)
gradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(25,25,25)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(90,0,0))
}
gradient.Rotation = 90

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.fromScale(1,0.22)
title.Text = "🔒 iSylHub Premium Key"
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(255,255,255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold

local tb = Instance.new("TextBox", frame)
tb.Size = UDim2.fromScale(0.9,0.22)
tb.Position = UDim2.fromScale(0.05,0.3)
tb.PlaceholderText = "Masukkan key kamu disini..."
tb.ClearTextOnFocus = false
tb.Text = ""
tb.TextColor3 = Color3.fromRGB(255,255,255)
tb.BackgroundColor3 = Color3.fromRGB(30,30,30)
tb.TextScaled = true
tb.PlaceholderColor3 = Color3.fromRGB(180,180,180)
tb.Parent = frame

local tbCorner = Instance.new("UICorner", tb)
tbCorner.CornerRadius = UDim.new(0,6)

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.fromScale(0.9,0.13)
status.Position = UDim2.fromScale(0.05,0.54)
status.BackgroundTransparency = 1
status.TextColor3 = Color3.fromRGB(255,200,120)
status.TextScaled = true
status.Text = ""
status.Font = Enum.Font.GothamMedium
status.Parent = frame

local btnCheck = Instance.new("TextButton", frame)
btnCheck.Size = UDim2.fromScale(0.43,0.2)
btnCheck.Position = UDim2.fromScale(0.05,0.74)
btnCheck.Text = "CHECK KEY"
btnCheck.BackgroundColor3 = Color3.fromRGB(25,25,25)
btnCheck.TextColor3 = Color3.fromRGB(255,90,90)
btnCheck.TextScaled = true
btnCheck.Font = Enum.Font.GothamBold
btnCheck.Parent = frame
Instance.new("UICorner", btnCheck).CornerRadius = UDim.new(0,6)

local btnGet = Instance.new("TextButton", frame)
btnGet.Size = UDim2.fromScale(0.43,0.2)
btnGet.Position = UDim2.fromScale(0.52,0.74)
btnGet.Text = "GET KEY"
btnGet.BackgroundColor3 = Color3.fromRGB(25,25,25)
btnGet.TextColor3 = Color3.fromRGB(255,90,90)
btnGet.TextScaled = true
btnGet.Font = Enum.Font.GothamBold
btnGet.Parent = frame
Instance.new("UICorner", btnGet).CornerRadius = UDim.new(0,6)

-- Animasi fade-in (preserve original feel)
frame.BackgroundTransparency = 1
for _,v in pairs(frame:GetDescendants()) do
	if v:IsA("TextLabel") or v:IsA("TextBox") or v:IsA("TextButton") then
		v.TextTransparency = 1
	end
end
TweenService:Create(frame, TweenInfo.new(0.4), {BackgroundTransparency=0}):Play()
for _,v in pairs(frame:GetDescendants()) do
	if v:IsA("TextLabel") or v:IsA("TextBox") or v:IsA("TextButton") then
		TweenService:Create(v, TweenInfo.new(0.5), {TextTransparency=0}):Play()
	end
end

-- =========================
-- BUTTON ACTIONS
-- =========================
local function setButtonsEnabled(v)
	btnCheck.Active = v
	btnCheck.AutoButtonColor = v
	btnGet.Active = v
	btnGet.AutoButtonColor = v
end

btnCheck.MouseButton1Click:Connect(function()
	local key = tb.Text:gsub("%s+","")
	if key == "" then status.Text = "Isi key dulu." return end
	setButtonsEnabled(false)
	status.Text = "🔍 Memeriksa key..."
	local hwid = Analytics:GetClientId()
	local url = KEY_CHECK_URL .. "?key=" .. HttpService:UrlEncode(key) .. "&hwid=" .. HttpService:UrlEncode(hwid)
	local res = safe_get(url)
	if not res then status.Text = "Gagal hubung server."; setButtonsEnabled(true) return end

	local ok,json = pcall(function() return HttpService:JSONDecode(res) end)
	if not ok or type(json)~="table" then
		status.Text = "Response server tidak valid."; setButtonsEnabled(true); return
	end

	if is_hwid_reset_response(json) then do_hwid_kick() return end
	if json.ok then
		status.Text = json.msg or "Key valid, memuat..."
		task.wait(0.3)
		on_key_valid(key)
	else
		status.Text = json.msg or "Key tidak valid."
		setButtonsEnabled(true)
	end
end)

btnGet.MouseButton1Click:Connect(function()
	if setclipboard then
		pcall(setclipboard, GET_KEY_URL)
		status.Text = "🔗 Link key disalin ke clipboard!"
	else
		status.Text = "Salin manual: "..GET_KEY_URL
	end
end)

-- auto-fill cache
local auto = load_cache()
if auto then
	tb.Text = auto
	status.Text = "Key ditemukan di cache. Tekan CHECK untuk verifikasi."
end
