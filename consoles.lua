---
-- Console support for premake.
-- Copyright (c) 2017 Blizzard Entertainment
---

if not premake.modules.consoles then
	premake.modules.consoles = {}
	local blizzard = premake.modules.consoles

	-- xbox
	include 'xbox.lua'
	include 'durango.lua'
	include 'durango_appxmanifest.lua'
	include 'scarlett.lua'
	include 'xboxone_gdk.lua'
end
