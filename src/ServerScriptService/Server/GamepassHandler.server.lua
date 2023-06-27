-- Services --
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Teams = game:GetService("Teams")
local ServerStorage = game:GetService("ServerStorage")

-- Variables --
local gamepassEvent = ReplicatedStorage.GUI.BuyGamepass
local gunEvent = ReplicatedStorage.Remotes.GunEvent

-- CONSTANTS --
local RELOAD_GAMEPASS = 196150694
local KNIFE_GAMEPASS = 196147867

local RELOAD_PERCENT = 0.65

-- Functions --
local function onChildAdded(child)
    if not child:IsA("Tool") then return end
    if not child:GetAttribute("GunType") then return end
    if child:GetAttribute("ReloadBuff") then return end
    local player = Players:GetPlayerFromCharacter(child.Parent)

    child:SetAttribute("ReloadBuff", true)
    local properties = require(child.Properties)
    properties.ReloadDuration *= RELOAD_PERCENT
    gunEvent:FireClient(player, "UpdateProperty", child, "ReloadDuration", properties.ReloadDuration)
end

local function onCharacterAdded(character : Model)
    local player = Players:GetPlayerFromCharacter(character)
    if player:GetAttribute("KnifeGamepass") then
        if player.Team == Teams.Alive then
            local clone = ServerStorage.Tools["Golden Knife"]:Clone()
            clone.Parent = player.Backpack
        end
    end
    if player:GetAttribute("ReloadGamepass") then
        character.ChildAdded:Connect(onChildAdded)
    end
end

local function onPlayerAdded(player : Player)
    local success, result = pcall(function()
        return MarketplaceService:UserOwnsGamePassAsync(player.UserId, RELOAD_GAMEPASS)
    end)
    if not success then
        print("Error while attempting to check gamepass status for player. \n"..result)
    elseif result then
        player:SetAttribute("ReloadGamepass", true)
    end

    success, result = pcall(function()
        return MarketplaceService:UserOwnsGamePassAsync(player.UserId, KNIFE_GAMEPASS)
    end)
    if not success then
        print("Error while attempting to check gamepass status for player. \n"..result)
    elseif result then
        player:SetAttribute("KnifeGamepass", true)
    end
    player.CharacterAdded:Connect(onCharacterAdded)
end

-- Event handlers --
Players.PlayerAdded:Connect(onPlayerAdded)

gamepassEvent.OnServerEvent:Connect(function(player, item)
    if item == "FasterReload" then
        MarketplaceService:PromptGamePassPurchase(player, RELOAD_GAMEPASS)
    elseif item == "GoldenKnife" then
        MarketplaceService:PromptGamePassPurchase(player, KNIFE_GAMEPASS)
    end
end)

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamePassId, wasPurchased)
    if gamePassId == RELOAD_GAMEPASS and wasPurchased then
        player:SetAttribute("ReloadGamepass", true)
    elseif gamePassId == KNIFE_GAMEPASS and wasPurchased then
        player:SetAttribute("KnifeGamepass", true)
    end
end)