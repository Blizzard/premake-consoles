---
-- Console support for premake.
-- Copyright (c) 2017 Blizzard Entertainment
---

	local p = premake
	local suite = test.declare("test_durango_project")
	local vc2010 = p.vstudio.vc2010


--
-- Setup
--

	local wks, prj

	function suite.setup()
		p.action.set("vs2015")
		wks = test.createWorkspace()
	end

	local function prepare()
		prj = test.getproject(wks, 1)
		vc2010.projectConfigurations(prj)
	end

