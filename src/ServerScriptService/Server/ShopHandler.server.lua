-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

-- Variables --
local shop = workspace.Shop.Shop
local prompt = shop.ProximityPart.ProximityPrompt
local gui = shop.BillboardGui
local shopGui = ReplicatedStorage.Shared.GUIs.ShopGui
local gameEnum = {"START_INTERMISSION", "INTERMISSION", "WAVE_IN_PROGRESS", "GAME_OVER", "WAITTING"}
local prices = {
    ["Pistol"] = {60, ServerStorage.Tools.Pistol},
    ["SMG"] = {100, ServerStorage.Tools.SMG},
    ["Rifle"] = {200, ServerStorage.Tools["Assault Rifle"]},
    ["Shotgun"] = {200, ServerStorage.Tools.Shotgun},
    ["ShotgunSlugs"] = {250},
    ["Medkit"] = {30, ServerStorage.Tools.Medkit},
    ["Grenade"] = {30, ServerStorage.Tools.Grenade}
}
local buyEvent = ReplicatedStorage.GUI.BuyItem

-- Listener --
workspace.AttributeChanged:Connect(function(name)
    if name ~= "GameState" then return end

    local gameState = workspace:GetAttribute("GameState")
    if gameState == gameEnum[1] or gameState == gameEnum[2] then
        prompt.Enabled = true
        gui.Enabled = true
    else
        prompt.Enabled = false
        gui.Enabled = false
    end
end)

buyEvent.OnServerEvent:Connect(function(player, nameOfItem)
    local gameState = workspace:GetAttribute("GameState")
    if gameState ~= gameEnum[1] and gameState ~= gameEnum[2] then return end
    if not prices[nameOfItem] then return end

    local afterBalance = player.leaderstats.Money.Value - prices[nameOfItem][1]
    if afterBalance < 0 then return end
    if (player.Backpack:FindFirstChild(prices[nameOfItem][2].Name) 
    or player.Character:FindFirstChild(prices[nameOfItem][2].Name))
    and prices[nameOfItem][2].Name ~= "Medkit" then
        return
    end
    if nameOfItem == "Grenade" then
        local grenadeTool = nil
        for _,tool in ipairs(player.Backpack:GetChildren()) do
            if string.find(tool.Name, "Grenade") then
                grenadeTool = tool
            end
        end
        if not grenadeTool then
            grenadeTool = player.Character:FindFirstChildWhichIsA("Tool")
        end
        if grenadeTool and grenadeTool:GetAttribute("GrenadesLeft") then
            if grenadeTool:GetAttribute("GrenadesLeft") == grenadeTool:GetAttribute("MaxGrenades") then return end
            grenadeTool:SetAttribute("GrenadesLeft", grenadeTool:GetAttribute("GrenadesLeft") + 1)
            player.leaderstats.Money.Value = afterBalance
            return
        end
    end

    player.leaderstats.Money.Value = afterBalance
    local clone = prices[nameOfItem][2]:Clone()
    clone.Parent = player.Backpack
end)

prompt.Triggered:Connect(function(player)
    local gameState = workspace:GetAttribute("GameState")
    if gameState ~= gameEnum[1] and gameState ~= gameEnum[2] then return end

    if player.PlayerGui:FindFirstChild("ShopGui") then
        player.PlayerGui.ShopGui:Destroy()
    end
    local clone = shopGui:Clone()
    clone.Parent = player.PlayerGui
end)