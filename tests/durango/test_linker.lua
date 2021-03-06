--
-- Xbox One XDK tests
-- Copyright Blizzard Entertainment, Inc
--

	local p = premake
	local suite = test.declare("durango_linker")
	local vc2010 = p.vstudio.vc2010


--
-- Setup
--

	local wks, prj

	function suite.setup()
		p.action.set("vs2017")
		wks, prj = test.createWorkspace()
	end

	local function prepare()
		kind "WindowedApp"
		system "durango"
		local cfg = test.getconfig(prj, "Debug", platform)
		vc2010.linker(cfg)
	end

	function suite.emptyAdditionalDependencies()
		prepare()
		test.capture [[
<Link>
	<SubSystem>Windows</SubSystem>
</Link>
		]]
	end

	function suite.additionalDependencies()
		links { 'kernelx' }
		prepare()
		test.capture [[
<Link>
	<SubSystem>Windows</SubSystem>
	<AdditionalDependencies>kernelx.lib</AdditionalDependencies>
</Link>
		]]
	end
