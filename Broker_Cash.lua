--[[  
  Project     : Broker Pack
  Copyright   : Copyright (c) 2011-2014 Frank Meus. All rights reserved.
  Purpose     :
--]]

-- Local variables
local cashStart, cashGain, cashLoss, cashLast = 0, 0, 0, 0;
local GOLD = GOLD_AMOUNT:gsub("%%d", "%(%%d+%)");
local SILVER = SILVER_AMOUNT:gsub("%%d", "%(%%d+%)");
local COPPER = COPPER_AMOUNT:gsub("%%d", "%(%%d+%)");
local startCurrency, sessionCurrency= {}, {};


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


-- Handle changes in tokens
function f:CURRENCY_DISPLAY_UPDATE()
    for i = 1, GetCurrencyListSize() do
        local name, _, _, _, _, count = GetCurrencyListInfo( i );
        startCurrency[name] = ( startCurrency[name] or count );
        sessionCurrency[name] = count;
    end;
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
    end;
end;


-- Open currency tab when clicked
function ldbCash:OnClick( button )
    ToggleCharacter( "TokenFrame" );
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
    GameTooltip:AddDoubleLine( "-------------", "--------------------------" );
    GameTooltip:AddDoubleLine( "Cashflow", GetCoinTextureString( abs( cashflow ), 16 ),  fontColor.r, fontColor.g, fontColor.b );

    -- Add token info to tooltip
    for i = 1, GetCurrencyListSize() do
        local name, isHeader, _, _, _, count, icon = GetCurrencyListInfo( i );
        if ( isHeader ) then
            GameTooltip:AddLine( "|n"..name, 1.0, 1.0, 1.0 );
        elseif ( count > 0 ) then
            local diff = ( sessionCurrency[name] or 0 ) - ( startCurrency[name] or 0 );
            if ( diff > 0 ) then
                GameTooltip:AddDoubleLine( "  |T"..icon..":0|t "..name, count.."  (|cFF3366FF+"..diff.."|r)" );
            elseif ( diff < 0 ) then
                GameTooltip:AddDoubleLine( "  |T"..icon..":0|t "..name, count.."  (|cFFFF5533"..diff.."|r)" );
            else
                GameTooltip:AddDoubleLine( "  |T"..icon..":0|t "..name, count );
            end;
        end;
    end;

    GameTooltip:AddLine( "|n<Left Click> to open/close Currency tab", 0.5, 0.5, 0.5 );
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
f:RegisterEvent( "CURRENCY_DISPLAY_UPDATE" );