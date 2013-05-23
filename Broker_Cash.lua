--[[  
  Project     : Broker Pack
  Copyright   : Copyright (c) 2011-2013 Frank Meus. All rights reserved.
  Purpose     :
--]]

-- Local variables
local cashStart, cashGain, cashLoss, cashLast, cashGuild = 0, 0, 0, 0, 0;
local GOLD = GOLD_AMOUNT:gsub("%%d", "%(%%d+%)");
local SILVER = SILVER_AMOUNT:gsub("%%d", "%(%%d+%)");
local COPPER = COPPER_AMOUNT:gsub("%%d", "%(%%d+%)");


-- Library stuff
local LibStub   = LibStub;
local LDB       = LibStub:GetLibrary("LibDataBroker-1.1");


-- Create frame for responding to game events
local f = CreateFrame( "Frame", "Broker_Cash", UIParent );


-- Setup broker
local ldbCash = LDB:NewDataObject( "Broker - Cash", {
    type    = "data source",
    icon    = "Interface\\Icons\\INV_Misc_Coin_01",
    text    = GetCoinTextureString( GetMoney(), 16 ),
    OnEnter = function( self )
        ldbCash_OnEnter( self )
    end,
    OnLeave = function()
        ldbCash_OnLeave()
    end
});


-- Initialize when player logs in
function f:PLAYER_LOGIN()
    f:RegisterEvent( "PLAYER_MONEY" );
    f:UnregisterEvent( "PLAYER_LOGIN" );
    
    cashStart, cashGain, cashLoss = GetMoney(), 0, 0;
    cashLast = cashStart;

    ldbCash.text = GetCoinTextureString( cashStart, 16 );
end;


-- Handle changes in cash
function f:PLAYER_MONEY( self, event, ... )
    local cashCurrent = GetMoney();
    local cashDiff = cashCurrent - cashLast;
    
    ldbCash.text = GetCoinTextureString( cashCurrent, 16 );

    if ( cashDiff >= 0 ) then
        cashGain = cashGain + cashDiff;
    else
        cashLoss = cashLoss - cashDiff;
    end;

    cashLast = cashCurrent;
end;


-- Handle cash from looting
function f:CHAT_MSG_MONEY( event, message, sender, language, channelString, target, flags, unknown, channelNumber, channelName, unknown, counter )
    if ( IsInGuild() ) then
        -- Parse the message for money gained
        local gold = message:match( GOLD );
        local silver = message:match( SILVER );
        local copper = message:match( COPPER );
        gold = ( gold and tonumber(gold) ) or 0;
        silver = ( silver and tonumber(silver) ) or 0;
        copper = ( copper and tonumber(copper) ) or 0;
        local money = copper + silver * 100 + gold * 10000;

        -- Determine cashflow factor
        local factor;
        if ( GetGuildLevel() >= 5 ) then factor = 0.05; end;
        if ( GetGuildLevel() >= 16 ) then factor = 0.10; end;
        cashGuild = cashGuild + math.floor( money * factor + 0.5 );
    end;
end;


-- Show tooltip
function ldbCash_OnEnter( self )
    local fontColor = {};
    local cashflow = cashGain - cashLoss;
    if ( cashflow < 0 ) then fontColor = RED_FONT_COLOR else fontColor = GREEN_FONT_COLOR end;

    GameTooltip:SetOwner( self, "ANCHOR_NONE" );
    GameTooltip:SetPoint( "TOPLEFT", self, "BOTTOMLEFT" );
    GameTooltip:ClearLines();
    GameTooltip:AddLine( "Cashflow|n|n", 1, 1, 1 );
    GameTooltip:AddDoubleLine( "Gained", GetCoinTextureString( cashGain, 16 ) );
    GameTooltip:AddDoubleLine( "Spent", GetCoinTextureString( cashLoss, 16 ) );
    GameTooltip:AddLine( "|n", 1, 1, 1 );
    GameTooltip:AddDoubleLine( "Cashflow", GetCoinTextureString( abs( cashflow ), 16 ),  fontColor.r, fontColor.g, fontColor.b );

    if ( IsInGuild() ) then
        GameTooltip:AddLine( "|n"  );
        GameTooltip:AddDoubleLine( "GB Cashflow", GetCoinTextureString( abs( cashGuild ), 16 ) );
    end;
    
    GameTooltip:Show();
end;


-- Hide tooltip
function ldbCash_OnLeave()
    GameTooltip:Hide();
end;


-- Generic event handler
local function OnEvent( self, event, ... )
    self[event]( self, event, ... );
end;


-- Setup event handler
f:SetScript( "OnEvent", OnEvent );


-- Register events to listen to
f:RegisterEvent( "PLAYER_LOGIN" );
f:RegisterEvent( "CHAT_MSG_MONEY" );