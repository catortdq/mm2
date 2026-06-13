-- MM2-Style Trade Request Script
-- Usage: loadstring(game:HttpGet("YOUR_URL_HERE"))()
-- This script sends a trade request to a specific player by UserId

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ============================================
-- CONFIGURATION
-- ============================================

-- Target UserId to send trade request to
-- Replace this with the actual UserId you want to trade with
local TARGET_USERID = 123456789  -- Example: Replace with actual UserId

-- RemoteEvent name for trade requests (MM2 uses this)
local TRADE_REMOTE_NAME = "TradeRequest"

-- ============================================
-- TRADE REQUEST FUNCTION
-- ============================================

local function sendTradeRequest(targetUserId)
    -- Find the target player by UserId
    local targetPlayer = Players:GetPlayerByUserId(targetUserId)
    
    if not targetPlayer then
        warn("Player with UserId " .. targetUserId .. " not found in the server")
        return false
    end
    
    -- Find the trade RemoteEvent
    local tradeRemote = game:GetService("ReplicatedStorage"):FindFirstChild(TRADE_REMOTE_NAME)
    
    if not tradeRemote then
        warn("TradeRequest RemoteEvent not found in ReplicatedStorage")
        return false
    end
    
    -- Send trade request to the target player
    -- MM2 expects: (targetPlayer, tradeData)
    local tradeData = {
        sender = LocalPlayer.Name,
        senderId = LocalPlayer.UserId,
        items = {}  -- Add your items here if needed
    }
    
    tradeRemote:FireServer(targetPlayer, tradeData)
    
    print("Trade request sent to " .. targetPlayer.Name .. " (UserId: " .. targetUserId .. ")")
    return true
end

-- ============================================
-- EXECUTE TRADE REQUEST
-- ============================================

-- Send the trade request when script loads
local success = sendTradeRequest(TARGET_USERID)

if success then
    print("Trade request sent successfully!")
else
    print("Failed to send trade request. Check the warnings above.")
end
