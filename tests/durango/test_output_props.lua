--
-- Xbox One XDK tests
-- Copyright Blizzard Entertainment, Inc
--

	local p = premake
	local suite = test.declare("durango_output_props")
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
		local cfg = test.getconfig(prj, "Debug")
		vc2010.outputProperties(cfg)
	end

	function suite.onDefaultValues()
		prepare()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Durango'">
	<LinkIncremental>true</LinkIncremental>
	<OutDir>bin\Debug\</OutDir>
	<IntDir>obj\Debug\</IntDir>
	<TargetName>MyProject</TargetName>
	<TargetExt>.exe</TargetExt>
	<IncludePath>$(Console_SdkIncludeRoot)</IncludePath>
	<LibraryPath>$(Console_SdkLibPath)</LibraryPath>
	<ExecutablePath>$(Console_SdkRoot)bin;$(VCInstallDir)bin\x86_amd64;$(VCInstallDir)bin;$(WindowsSDK_ExecutablePath_x86);$(VSInstallDir)Common7\Tools\bin;$(VSInstallDir)Common7\tools;$(VSInstallDir)Common7\ide;$(ProgramFiles)\HTML Help Workshop;$(MSBuildToolsPath32);$(FxCopDir);$(PATH)</ExecutablePath>
	<ReferencePath>$(Console_SdkLibPath);$(Console_SdkWindowsMetadataPath)</ReferencePath>
	<LibraryWPath>$(Console_SdkLibPath);$(Console_SdkWindowsMetadataPath)</LibraryWPath>
</PropertyGroup>
		]]
	end

	function suite.onLayout()
		xbox_layoutdir 'testdir'
		prepare()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Durango'">
	<LinkIncremental>true</LinkIncremental>
	<OutDir>bin\Debug\</OutDir>
	<IntDir>obj\Debug\</IntDir>
	<TargetName>MyProject</TargetName>
	<TargetExt>.exe</TargetExt>
	<IncludePath>$(Console_SdkIncludeRoot)</IncludePath>
	<LibraryPath>$(Console_SdkLibPath)</LibraryPath>
	<ExecutablePath>$(Console_SdkRoot)bin;$(VCInstallDir)bin\x86_amd64;$(VCInstallDir)bin;$(WindowsSDK_ExecutablePath_x86);$(VSInstallDir)Common7\Tools\bin;$(VSInstallDir)Common7\tools;$(VSInstallDir)Common7\ide;$(ProgramFiles)\HTML Help Workshop;$(MSBuildToolsPath32);$(FxCopDir);$(PATH)</ExecutablePath>
	<ReferencePath>$(Console_SdkLibPath);$(Console_SdkWindowsMetadataPath)</ReferencePath>
	<LibraryWPath>$(Console_SdkLibPath);$(Console_SdkWindowsMetadataPath)</LibraryWPath>
	<LayoutDir>testdir</LayoutDir>
</PropertyGroup>
		]]
	end
