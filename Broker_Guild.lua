--[[  
  Project     : Broker Pack
  Copyright   : Copyright (c) 2011-2014 Frank Meus. All rights reserved.
  Purpose     :
--]]

-- Local variables
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
        local numMembers, onlineMembers, numOnlineAndMobile = GetNumGuildMembers();

        ldbGuild.text = GUILD.." ["..numOnlineAndMobile.." / "..numMembers.."]";
    end;
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
        local numMembers, onlineMembers, numOnlineAndMobile = GetNumGuildMembers();

        -- Sort by name
        SortGuildRoster( "name" );

        for i = 1, numOnlineAndMobile do 
            -- get info
            local name, rank, rankIndex, level, class, zone, note, officernote, online, status, classFileName, achievementPoints, achievementRank, isMobile, canSoR, reputation = GetGuildRosterInfo( i );
            
            if ( online or isMobile ) then
                tLeft, tRight, tTop, tBottom = unpack( CLASS_ICON_TCOORDS[classFileName] );
                if ( isMobile ) then
                    icon = "|TInterface\\ChatFrame\\UI-ChatIcon-ArmoryChat-AwayMobile:14:14:0:0:16:16:0:16:0:16|t";
                else
                    icon = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes:14:14:0:0:256:256:"..(tLeft*256)..":"..(tRight*256)..":"..(tTop*256)..":"..(tBottom*256).."|t";
                end;
                GameTooltip:AddDoubleLine( icon.." "..name.." - "..( zone or "??" ), UI_STATUS[status].." "..level );
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
f:RegisterEvent( "PLAYER_ENTERING_WORLD" );