--
-- Console support for premake.
-- Copyright Blizzard Entertainment, Inc
--

if not premake.modules.consoles then
	premake.modules.consoles = {}
	local blizzard = premake.modules.consoles

	-- xbox
	include 'xbox.lua'
	include 'durango.lua'
	include 'scarlett.lua'
	include 'xboxone_gdk.lua'
end
