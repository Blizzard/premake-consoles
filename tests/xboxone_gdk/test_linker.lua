--
-- Xbox One GDK tests
-- Copyright Blizzard Entertainment, Inc
--

	local p = premake
	local suite = test.declare("xboxone_gdk_linker")
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
		local cfg = test.getconfig(prj, "Debug", platform)
		vc2010.linker(cfg)
	end

	function suite.emptyAdditionalDependencies()
		prepare()
		test.capture [[
<Link>
	<SubSystem>Windows</SubSystem>
	<AdditionalDependencies>$(Console_Libs);%(XboxExtensionsDependencies)</AdditionalDependencies>
</Link>
		]]
	end

	function suite.additionalDependencies()
		links { 'kernelx' }
		prepare()
		test.capture [[
<Link>
	<SubSystem>Windows</SubSystem>
	<AdditionalDependencies>kernelx.lib;$(Console_Libs);%(XboxExtensionsDependencies)</AdditionalDependencies>
</Link>
		]]
	end
