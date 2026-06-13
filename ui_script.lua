--[[
    Server-Authoritative Trading System
    Place this script in ServerScriptService
    
    Features:
    - Whitelist-based trade acceptance
    - Server-side validation only
    - RemoteEvent spoofing protection
    - UserId-based authentication
    - Rate limiting
    - Comprehensive logging
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ============================================
-- CONFIGURATION
-- ============================================

-- Whitelist of UserIds allowed to trade with you
-- Replace these with actual UserIds from your trusted users
local WHITELISTED_USERIDS = {
    123456789,  -- Example: Replace with actual UserId
    987654321,  -- Example: Replace with actual UserId
    -- Add more UserIds as needed
}

-- RemoteEvent name for trade requests
local TRADE_REMOTE_NAME = "TradeRequest"

-- Rate limiting: Maximum trades per minute per player
local MAX_TRADES_PER_MINUTE = 10

-- ============================================
-- SECURITY & VALIDATION
-- ============================================

-- Track trade requests for rate limiting
local playerTradeCounts = {}
local lastCleanupTime = tick()

-- Validate that a player is legitimate
local function validatePlayer(player)
    if not player or not player:IsA("Player") then
        return false, "Invalid player"
    end
    
    if not player.UserId or player.UserId <= 0 then
        return false, "Invalid UserId"
    end
    
    return true, nil
end

-- Check if player is rate limited
local function checkRateLimit(player)
    local currentTime = tick()
    
    -- Clean up old entries every minute
    if currentTime - lastCleanupTime > 60 then
        for userId, data in pairs(playerTradeCounts) do
            if currentTime - data.lastTradeTime > 60 then
                playerTradeCounts[userId] = nil
            end
        end
        lastCleanupTime = currentTime
    end
    
    -- Check current player's trade count
    local playerData = playerTradeCounts[player.UserId] or { count = 0, lastTradeTime = currentTime }
    
    if currentTime - playerData.lastTradeTime > 60 then
        -- Reset count if more than a minute has passed
        playerData.count = 0
    end
    
    if playerData.count >= MAX_TRADES_PER_MINUTE then
        return false, "Rate limit exceeded"
    end
    
    return true, nil
end

-- Update rate limit counter
local function updateRateLimit(player)
    local playerData = playerTradeCounts[player.UserId] or { count = 0, lastTradeTime = tick() }
    playerData.count = playerData.count + 1
    playerData.lastTradeTime = tick()
    playerTradeCounts[player.UserId] = playerData
end

-- Check if UserId is whitelisted
local function isWhitelisted(userId)
    for _, whitelistedId in ipairs(WHITELISTED_USERIDS) do
        if whitelistedId == userId then
            return true
        end
    end
    return false
end

-- ============================================
-- TRADE REQUEST HANDLING
-- ============================================

-- Create or get the RemoteEvent
local tradeRemote = ReplicatedStorage:FindFirstChild(TRADE_REMOTE_NAME)
if not tradeRemote then
    tradeRemote = Instance.new("RemoteEvent")
    tradeRemote.Name = TRADE_REMOTE_NAME
    tradeRemote.Parent = ReplicatedStorage
    warn("Created TradeRequest RemoteEvent in ReplicatedStorage")
end

-- Log trade activity
local function logTradeActivity(action, sender, receiver, reason)
    local logMessage = string.format(
        "[TradeSystem] %s | Sender: %s (%d) | Receiver: %s (%d) | Reason: %s",
        action,
        sender.Name,
        sender.UserId,
        receiver.Name,
        receiver.UserId,
        reason or "N/A"
    )
    print(logMessage)
end

-- Handle incoming trade requests
tradeRemote.OnServerEvent:Connect(function(player, targetPlayer, tradeData)
    -- ============================================
    -- SECURITY: Validate sender
    -- ============================================
    local isValid, errorMsg = validatePlayer(player)
    if not isValid then
        warn(string.format("[Security] Invalid trade request from: %s - %s", tostring(player), errorMsg))
        return
    end
    
    -- ============================================
    -- SECURITY: Check rate limiting
    -- ============================================
    local canTrade, rateError = checkRateLimit(player)
    if not canTrade then
        warn(string.format("[Security] Rate limit hit for player %s (%d)", player.Name, player.UserId))
        tradeRemote:FireClient(player, "REJECTED", rateError)
        return
    end
    
    -- ============================================
    -- SECURITY: Validate target player
    -- ============================================
    if not targetPlayer or not targetPlayer:IsA("Player") then
        warn(string.format("[Security] Invalid target player from %s", player.Name))
        tradeRemote:FireClient(player, "REJECTED", "Invalid target player")
        return
    end
    
    -- ============================================
    -- SECURITY: Validate trade data structure
    -- ============================================
    if type(tradeData) ~= "table" then
        warn(string.format("[Security] Invalid trade data format from %s", player.Name))
        tradeRemote:FireClient(player, "REJECTED", "Invalid trade data")
        return
    end
    
    -- ============================================
    -- SECURITY: Check for self-trading
    -- ============================================
    if player.UserId == targetPlayer.UserId then
        warn(string.format("[Security] Self-trade attempt by %s", player.Name))
        tradeRemote:FireClient(player, "REJECTED", "Cannot trade with yourself")
        return
    end
    
    -- ============================================
    -- WHITELIST CHECK
    -- ============================================
    local senderWhitelisted = isWhitelisted(player.UserId)
    local targetWhitelisted = isWhitelisted(targetPlayer.UserId)
    
    -- Log the trade request
    logTradeActivity("REQUEST", player, targetPlayer, 
        string.format("Sender Whitelisted: %s | Target Whitelisted: %s", 
            tostring(senderWhitelisted), tostring(targetWhitelisted)))
    
    -- ============================================
    -- TRADE DECISION LOGIC
    -- ============================================
    
    -- Accept if sender is whitelisted
    if senderWhitelisted then
        updateRateLimit(player)
        
        -- Here you would implement your actual trade logic
        -- For example: validate items, transfer ownership, etc.
        
        -- Notify sender of acceptance
        tradeRemote:FireClient(player, "ACCEPTED", "Trade accepted - you are whitelisted")
        
        -- Notify target player
        tradeRemote:FireClient(targetPlayer, "TRADE_REQUEST", {
            sender = player.Name,
            senderId = player.UserId,
            tradeData = tradeData
        })
        
        logTradeActivity("ACCEPTED", player, targetPlayer, "Sender is whitelisted")
        return
    end
    
    -- Reject if sender is not whitelisted
    tradeRemote:FireClient(player, "REJECTED", "You are not whitelisted for trading")
    logTradeActivity("REJECTED", player, targetPlayer, "Sender not whitelisted")
end)

-- ============================================
-- PLAYER CLEANUP
-- ============================================

-- Clean up rate limit data when players leave
Players.PlayerRemoving:Connect(function(player)
    playerTradeCounts[player.UserId] = nil
    print(string.format("[TradeSystem] Cleaned up data for player: %s", player.Name))
end)

print("[TradeSystem] Server-authoritative trading system initialized")
print(string.format("[TradeSystem] Whitelisted UserIds: %d", #WHITELISTED_USERIDS))
