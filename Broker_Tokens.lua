--[[  
  Project     : Broker Pack

  Copyright   : Copyright (c) 2011-2013 Frank Meus. All rights reserved.

  Purpose     :

  Revision    : $Id: Broker_Tokens.lua 737 2013-01-23 22:11:26Z fmeus_lgs $
--]]

-- Local variables
local startCurrency, sessionCurrency= {}, {};


-- Library stuff
local LibStub   = LibStub;
local LDB       = LibStub:GetLibrary("LibDataBroker-1.1");


-- Create frame for responding to game events
local f = CreateFrame( "Frame", "Broker_Tokens", UIParent );


-- Setup broker
local ldbTokens = LDB:NewDataObject( "Broker - Tokens", {
    type    = "data source",
    icon    = GetItemIcon( 29434 ),
    text    = TOKENS,
    OnEnter = function( self )
        ldbTokens_OnEnter( self )
    end,
    OnLeave = function()
        ldbTokens_OnLeave()
    end
});


-- Handle changes in tokens
function f:CURRENCY_DISPLAY_UPDATE()
    for i = 1, GetCurrencyListSize() do
        local name, _, _, _, _, count = GetCurrencyListInfo( i );
        startCurrency[name] = ( startCurrency[name] or count );
        sessionCurrency[name] = count;
    end;
end;


-- Open currency tab when clicked
function ldbTokens:OnClick( button )
    ToggleCharacter( "TokenFrame" );
end;


-- Show tooltip
function ldbTokens_OnEnter( self, motion )
    GameTooltip:SetOwner( self, "ANCHOR_NONE" );
    GameTooltip:SetPoint( "TOPLEFT", self, "BOTTOMLEFT" );
    GameTooltip:ClearLines();
    GameTooltip:AddLine( TOKENS, 1, 1, 1 );

    -- Add info to tooltip
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
function ldbTokens_OnLeave()
    GameTooltip:Hide();
end;


-- Generic event handler
local function OnEvent( self, event, ... )
    self[event]( self, event, ... );
end;


-- Setup event handler
f:SetScript( "OnEvent", OnEvent );


-- Register events to listen to
f:RegisterEvent( "CURRENCY_DISPLAY_UPDATE" );