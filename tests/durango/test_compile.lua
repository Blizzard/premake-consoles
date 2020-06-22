---
-- Console support for premake.
-- Copyright (c) 2017 Blizzard Entertainment
---

	local p = premake
	local suite = test.declare("duranago_compile")
	local vc2010 = p.vstudio.vc2010


--
-- Setup
--

	local wks, prj

	function suite.setup()
		p.action.set("vs2015")
		wks, prj = test.createWorkspace()
	end

	local function prepare()
		kind "WindowedApp"
		system "durango"
		local cfg = test.getconfig(prj, "Debug", platform)
		vc2010.clCompile(cfg)
	end

	function suite.winrtNotSpecified()
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Disabled</Optimization>
	<CompileAsWinRT>false</CompileAsWinRT>
</ClCompile>
		]]
	end

	function suite.winrtOff()
		compileaswinrt 'Off'
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Disabled</Optimization>
	<CompileAsWinRT>false</CompileAsWinRT>
</ClCompile>
		]]
	end

	function suite.winrtOn()
		compileaswinrt 'On'
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<WarningLevel>Level3</WarningLevel>
	<Optimization>Disabled</Optimization>
	<CompileAsWinRT>true</CompileAsWinRT>
</ClCompile>
		]]
	end

