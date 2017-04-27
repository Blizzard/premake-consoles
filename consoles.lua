---
-- Console support for premake.
-- Copyright (c) 2017 Blizzard Entertainment
---

if not premake.modules.consoles then
	premake.modules.consoles = {}
	local blizzard = premake.modules.consoles

	include('durango.lua')
end
