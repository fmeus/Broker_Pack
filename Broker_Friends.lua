--[[  
  Project     : Broker Pack
  Copyright   : Copyright (c) 2011-2013 Frank Meus. All rights reserved.
  Purpose     :
--]]

-- Local variables
local onlineMembers = 0;
local UI_STATUS = { [0] = "", [1] = "<AFK>", [2] = "<DND>" };
local onlineFriends = 0;
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
local f = CreateFrame( "Frame", "Broker_Friends", UIParent );


-- Setup broker
local ldbFriends = LDB:NewDataObject( "Broker - Friends", {
    type    = "data source",
    icon    = "Interface\\FriendsFrame\\UI-Toast-ChatInviteIcon",
    text    = FRIENDS,
    OnEnter = function( self )
        ldbFriends_OnEnter( self )
    end,
    OnLeave = function()
        ldbFriends_OnLeave()
    end
});


-- Update text for the broker
local function updateFriends()
    local numFriends, numFriendsOnline = GetNumFriends();
    local numBNetTotal, numBNetOnline = BNGetNumFriends();
    ldbFriends.text = FRIENDS.." ["..numFriendsOnline+numBNetOnline.." / "..numFriends+numBNetTotal.."]";
end;


-- Handle changes to friend list
function f:FRIENDLIST_UPDATE()
    updateFriends();
end;


-- Handle changes to Battle.net friends
function f:BN_FRIEND_INFO_CHANGED()
    updateFriends();
end;


-- Open friends tab when clicked
function ldbFriends:OnClick( button )
    ToggleFriendsFrame(1);
end;


-- Show tooltip
function ldbFriends_OnEnter( self, motion )
    local numFriends, numFriendsOnline = GetNumFriends();
    local numBNetTotal, numBNetOnline = BNGetNumFriends();

    GameTooltip:SetOwner( self, "ANCHOR_NONE" );
    GameTooltip:SetPoint( "TOPLEFT", self, "BOTTOMLEFT" );
    GameTooltip:ClearLines();

    -- Battle.net friends
    if ( numBNetOnline > 0 ) then
        -- Add tooltip title
        GameTooltip:AddLine( "Battle.net friends", 1, 1, 1 );

        for i = 1, numBNetOnline do
            local presenceID, givenName, surname, toonName, toonID, client, isOnline, lastOnline, isAFK, isDND, messageText, noteText, isFriend, unknown = BNGetFriendInfo( i );
            GameTooltip:AddDoubleLine( " "..givenName.." "..(surname or ""), toonName );
        end;
    end;
    
    -- Game characters
    if ( numFriendsOnline > 0 ) then
        if ( numBNetOnline > 0 ) then
        GameTooltip:AddLine( " " );
        end;

        -- Add tooltip title
        GameTooltip:AddLine( SHOW_TOAST_ONLINE_TEXT, 1, 1, 1 );

        -- Add info to tooltip
        local tLeft, tRight, tTop, tBottom, icon;
        for i = 1, GetNumFriends() do 
            -- get info
            local name, level, class, area, connected, status, note, RAF = GetFriendInfo( i );
            if ( connected ) then
                tLeft, tRight, tTop, tBottom = unpack( CLASS_ICON_TCOORDS[classFileNames[class]] );
                icon = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes:14:14:0:0:256:256:"..(tLeft*256)..":"..(tRight*256)..":"..(tTop*256)..":"..(tBottom*256).."|t";
                
                GameTooltip:AddDoubleLine( icon.." "..name.." - "..( area or "??" ),  status.." "..level );
            end;
        end;
    end;

    if ( numBNetOnline+numFriendsOnline == 0 ) then
        GameTooltip:AddLine( "No friends currently online", 0.5, 0.5, 0.5 );
    end;

    GameTooltip:AddLine( "|n<Left Click> to open/close Friends tab", 0.5, 0.5, 0.5 );
    GameTooltip:Show();
end;


-- Hide tooltip
function ldbFriends_OnLeave()
    GameTooltip:Hide();
end;


-- Event to start collecting data
function f:PLAYER_ENTERING_WORLD()
    ShowFriends();
end


-- Generic event handler
local function OnEvent( self, event, ... )
    self[event]( self, event, ... );
end;


-- Setup event handler
f:SetScript( "OnEvent", OnEvent );


-- Register events to listen to
f:RegisterEvent( "FRIENDLIST_UPDATE" );
f:RegisterEvent( "BN_FRIEND_INFO_CHANGED" );
f:RegisterEvent( "PLAYER_ENTERING_WORLD" );