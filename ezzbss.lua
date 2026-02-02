local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "EzzBss",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "EzzBss",
   LoadingSubtitle = "by Solvibe and Memzad Prime",
   ShowText = "EzzBss", -- for mobile users to unhide rayfield, change if you'd like
   Theme = "Default", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   ToggleUIKeybind = "K", -- The keybind to toggle the UI visibility (string like "K" or Enum.KeyCode)

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "Preset 1"
   },

   Discord = {
      Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },

   KeySystem = false, -- Set this to true to use our key system
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided", -- Use this to tell the user how to get a key
      FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"Hello"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})

local home = Window:CreateTab("Home", 127099021069839) -- Title, Image
local alt = Window:CreateTab("Alt", 95949997618327)
local config = Window:CreateTab("Config", 102970103256222)

local Slider = home:CreateSlider({
   Name = "Slider Example",
   Range = {1, 24},
   Increment = 1,
   Suffix = "Restart time",
   CurrentValue = 10,
   Flag = "RestartTimeSlider", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
   -- The function that takes place when the slider changes
   -- The variable (Value) is a number which correlates to the value the slider is currently at
   end,
})

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local player = Players.LocalPlayer
local targetPlayerName = nil
local isTargetEnabled = false

local function rejoinSelf()
    TeleportService:Teleport(game.PlaceId, player)
end

local DropdownTargetPlayer = alt:CreateDropdown({
    Name = "TargetPlayer",
    Options = {},
    CurrentOption = {""},
    MultipleOptions = false,
    Flag = "PlayerInServer",
    Callback = function(Options)
        targetPlayerName = Options[1]
    end,
})

local ToggleTargetPlayer = alt:CreateToggle({
    Name = "Target Player",
    CurrentValue = false,
    Flag = "ToggleRestartAlt",
    Callback = function(Value)
        isTargetEnabled = Value
    end,
})

local function updatePlayers()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then
            table.insert(names, p.Name)
        end
    end
    DropdownTargetPlayer:Refresh(names, true)
end

updatePlayers()
Players.PlayerAdded:Connect(updatePlayers)
Players.PlayerRemoving:Connect(function(removedPlayer)
    updatePlayers()
    
    if isTargetEnabled and removedPlayer.Name == targetPlayerName then
        spawn(function()
            rejoinSelf()  -- Только ТЫ перезаходишь
        end)
    end
end)
local HttpService = game:GetService("HttpService")

local configFolder = "workspace\\Rayfield\\Configurations"

if not isfolder(configFolder) then
    makefolder(configFolder)
end

local function getConfigFiles()
    local files = {}
    if isfolder(configFolder) then
        for _, path in ipairs(listfiles(configFolder)) do
            if path:sub(-5) == ".rfld" then
                local name = path:match("([^/\\]+)%.rfld$") or path
                table.insert(files, name)
            end
        end
    end
    table.sort(files)
    return files
end

-- Жёстко ищем МАКСИМАЛЬНЫЙ номер среди всех "Preset N"
local function getNextPresetName()
    local maxIndex = 0
    local files = getConfigFiles()
    for _, name in ipairs(files) do
        local n = name:match("^Preset (%d+)$")
        n = tonumber(n)
        if n and n > maxIndex then
            maxIndex = n
        end
    end
    return "Preset " .. (maxIndex + 1)
end

local selectedConfig = nil

local DropdownConfig = config:CreateDropdown({
    Name = "Select Config",
    Options = getConfigFiles(),
    CurrentOption = {""},
    MultipleOptions = false,
    Flag = "Config",
    Callback = function(Options)
        selectedConfig = Options[1]
    end,
})

local ButtonConfigCreate = config:CreateButton({
    Name = "Create Config",
    Callback = function()
        local presetName = getNextPresetName()
        local filePath = configFolder .. "\\" .. presetName .. ".rfld"

        writefile(filePath, HttpService:JSONEncode({}))

        local opts = getConfigFiles()
        DropdownConfig:Refresh(opts, true)
        DropdownConfig:Set({presetName})
        selectedConfig = presetName
    end,
})

local ButtonConfig = config:CreateButton({
    Name = "Apply Config",
    Callback = function()
        if not selectedConfig then return end

        local filePath = configFolder .. "\\" .. selectedConfig .. ".rfld"
        if not isfile(filePath) then return end

        local content = readfile(filePath)
        local data = HttpService:JSONDecode(content)
    end,
})
