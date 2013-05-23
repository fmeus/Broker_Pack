--[[  
  Project     : Broker Pack
  Copyright   : Copyright (c) 2011-2013 Frank Meus. All rights reserved.
  Purpose     :
--]]

-- Local variables
local onlineMembers = 0;
local UI_STATUS = { [0] = "", [1] = "<AFK>", [2] = "<DND>" };
local classFileNames, classes = {}, {};


--  Build list for class file names
FillLocalizedClassList(classes, false);
for token, localizedName in pairs(classes) do
   classFileNames[localizedName] = token;
end;


-- Library stuff
local LibStub   = LibStub;
local LDB       = LibStub:GetLibrary("LibDataBroker-1.1");


-- Create frame for responding to game events
local f = CreateFrame( "Frame", "Broker_Guild", UIParent );


-- Setup broker
local ldbGuild = LDB:NewDataObject( "Broker - Guild", {
    type    = "data source",
    icon    = "Interface\\WorldStateFrame\\"..UnitFactionGroup( "player" ).."Icon",
    text    = GUILD,
    OnEnter = function( self )
        ldbGuild_OnEnter( self )
    end,
    OnLeave = function()
        ldbGuild_OnLeave()
    end
});


-- Handle changes in guild roster
function f:GUILD_ROSTER_UPDATE( self, event, ... )
    if ( IsInGuild() ) then
        onlineMembers = 0;

        -- Workaround to get online member total
        for i = 1, GetNumGuildMembers( true ) do 
            -- get info
            local name, rank, rankIndex, level, class, zone, note, officernote, online, status, classFileName = GetGuildRosterInfo(i)
            if ( online ) then
                onlineMembers = onlineMembers + 1;
            end;
        end;

        local guild_progression = "";
        if ( GetGuildLevel() < 25 ) then
            local currentXP, remainingXP = UnitGetGuildXP("player");
            local progress = string.format( "%.2f", ( currentXP / ( remainingXP + currentXP )*100 ) );
            local togo = string.format( "%.0f", (remainingXP / 60000 ) );
            guild_progression = " ["..GetGuildLevel().." - "..progress.."% (~ "..togo..")]";
        end;
        ldbGuild.text = GUILD.." ["..onlineMembers.." / "..GetNumGuildMembers( true ).."]"..guild_progression;
    end;
end;


-- Handle changes in guild experience
function f:GUILD_XP_UPDATE( self, event, ... )
    f:GUILD_ROSTER_UPDATE();
end;


-- Open guild frame when clicked
function ldbGuild:OnClick( button )
    GuildFrame_LoadUI();
    if ( GuildFrame_Toggle ) then
        GuildFrame_Toggle();
    end;
end;


-- Show tooltip
function ldbGuild_OnEnter( self, motion )
    GameTooltip:SetOwner( self, "ANCHOR_NONE" );
    GameTooltip:SetPoint( "TOPLEFT", self, "BOTTOMLEFT" );
    GameTooltip:ClearLines();

    if ( IsInGuild() ) then
        -- Add tooltip title
        GameTooltip:AddLine( GUILD.." - "..GetGuildInfo( "player" ).."|n|n", 1, 1, 1 );

        -- Add info to tooltip
        local tLeft, tRight, tTop, tBottom, icon;
        for i = 1, GetNumGuildMembers( true ) do 
            -- get info
            local name, rank, rankIndex, level, class, zone, note, officernote, online, status, classFileName = GetGuildRosterInfo(i)
            
            if ( online ) then
                tLeft, tRight, tTop, tBottom = unpack( CLASS_ICON_TCOORDS[classFileName] );
                icon = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes:14:14:0:0:256:256:"..(tLeft*256)..":"..(tRight*256)..":"..(tTop*256)..":"..(tBottom*256).."|t";
                GameTooltip:AddDoubleLine( icon.." "..name.." - "..( zone or "??" ),  UI_STATUS[status].." "..level );
            end;
        end;
    else
        GameTooltip:AddLine( ERR_GUILD_PLAYER_NOT_IN_GUILD, 0.5, 0.5, 0.5 );
    end;

    GameTooltip:AddLine( "|n<Left Click> to open/close Guild tab", 0.5, 0.5, 0.5 );
    GameTooltip:Show();
end;


-- Hide tooltip
function ldbGuild_OnLeave()
    GameTooltip:Hide();
end;


function f:PLAYER_ENTERING_WORLD()
    if IsInGuild() then
        QueryGuildXP();
        GuildRoster();
    end;
end


-- Generic event handler
local function OnEvent( self, event, ... )
    self[event]( self, event, ... );
end;


-- Setup event handler
f:SetScript( "OnEvent", OnEvent );


-- Register events to listen to
f:RegisterEvent( "GUILD_ROSTER_UPDATE" );
f:RegisterEvent( "GUILD_XP_UPDATE" );
f:RegisterEvent( "PLAYER_ENTERING_WORLD" );