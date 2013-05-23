--[[  
  Project     : Broker Pack
  Copyright   : Copyright (c) 2011-2013 Frank Meus. All rights reserved.
  Purpose     :
--]]

-- Local variables
local updateInterval, timeSinceLastUpdate = 0.5, 0.0;
local currentSpeed, groundSpeed, flightSpeed, swimSpeed = 0, 0, 0, 0;


-- Library stuff
local LibStub   = LibStub;
local LDB       = LibStub:GetLibrary("LibDataBroker-1.1");


-- Create frame for responding to game events
local f = CreateFrame( "Frame", "Broker_Speed", UIParent );


-- Setup broker
local ldbSpeed = LDB:NewDataObject( "Broker - Speed", {
    type    = "data source",
    icon    = "Interface\\WorldStateFrame\\"..UnitFactionGroup( "player" ).."Icon",
    text    = "Speed",
    OnEnter = function( self )
        ldbSpeed_OnEnter( self )
    end,
    OnLeave = function()
        ldbSpeed_OnLeave()
    end
});


-- Show tooltip
function ldbSpeed_OnEnter( self, motion )
    GameTooltip:SetOwner( self, "ANCHOR_NONE" );
    GameTooltip:SetPoint( "TOPLEFT", self, "BOTTOMLEFT" );
    GameTooltip:ClearLines();

    cs = math.floor( ( currentSpeed / 7 ) * 100 ).." %";
    gs = math.floor( ( groundSpeed / 7 ) * 100 ).." %";
    fs = math.floor( ( flightSpeed / 7 ) * 100 ).." %";
    ss = math.floor( ( swimSpeed / 7 ) * 100 ).." %";

    GameTooltip:AddLine( "Speed|n|n", 1, 1, 1 );
    GameTooltip:AddDoubleLine( "Current",  cs );
    GameTooltip:AddDoubleLine( "Ground",  gs );
    GameTooltip:AddDoubleLine( "Flighing",  fs );
    GameTooltip:AddDoubleLine( "Swimming",  ss );

    GameTooltip:Show();
end;


-- Hide tooltip
function ldbSpeed_OnLeave()
    GameTooltip:Hide();
end;


-- Event to start collecting data
function f:PLAYER_ENTERING_WORLD()
    currentSpeed, groundSpeed, flightSpeed, swimSpeed = GetUnitSpeed( "player" );
end


-- Generic event handler
local function OnEvent( self, event, ... )
    self[event]( self, event, ... );
end;


-- Generic event handler
local function OnUpdate( self, elapsed  )
    timeSinceLastUpdate = timeSinceLastUpdate + elapsed;
    
    if ( timeSinceLastUpdate > updateInterval ) then
        currentSpeed, groundSpeed, flightSpeed, swimSpeed = GetUnitSpeed( "player" );
        
        cs = math.floor( ( currentSpeed / 7 ) * 100 ).." %";
        ldbSpeed.text = "Speed - "..cs;

        timeSinceLastUpdate = 0;
    end;
end;


-- Setup event handler
f:SetScript( "OnEvent", OnEvent );
f:SetScript( "OnUpdate", OnUpdate );


-- Register events to listen to
f:RegisterEvent( "PLAYER_ENTERING_WORLD" );