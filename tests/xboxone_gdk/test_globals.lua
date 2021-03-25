--
-- Xbox One GDK tests
-- Copyright Blizzard Entertainment, Inc
--

	local p = premake
	local suite = test.declare("xboxone_gdk_globals")
	local vc2010 = p.vstudio.vc2010


--
-- Setup
--

	local wks, prj

	function suite.setup()
		p.action.set("vs2019")
		wks, prj = test.createWorkspace()
	end

	local function prepare()
		kind "WindowedApp"
		system "xboxone_gdk"
		prj = test.getproject(wks, 1)
		vc2010.globals(prj)
	end

	function suite.onDefaultValues()
		prepare()
		test.capture [[
<PropertyGroup Label="Globals">
	<ProjectGuid>{42B5DBC6-AE1F-903D-F75D-41E363076E92}</ProjectGuid>
	<IgnoreWarnCompileDuplicatedFilename>true</IgnoreWarnCompileDuplicatedFilename>
	<DefaultLanguage>en-US</DefaultLanguage>
	<TargetRuntime>Native</TargetRuntime>
</PropertyGroup>
		]]
	end
