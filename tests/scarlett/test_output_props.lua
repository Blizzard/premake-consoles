--
-- Xbox Series X/S tests
-- Copyright Blizzard Entertainment, Inc
--

	local p = premake
	local suite = test.declare("scarlett_output_props")
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
		system "scarlett"
		local cfg = test.getconfig(prj, "Debug")
		vc2010.outputProperties(cfg)
	end

	function suite.onDefaultValues()
		prepare()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Gaming.Xbox.Scarlett.x64'">
	<LinkIncremental>true</LinkIncremental>
	<OutDir>bin\Debug\</OutDir>
	<IntDir>obj\Debug\</IntDir>
	<TargetName>MyProject</TargetName>
	<TargetExt>.exe</TargetExt>
	<IncludePath>$(Console_SdkIncludeRoot)</IncludePath>
	<LibraryPath>$(Console_SdkLibPath)</LibraryPath>
	<EmbedManifest>false</EmbedManifest>
	<GenerateManifest>false</GenerateManifest>
	<ExecutablePath>$(Console_SdkRoot)bin;$(Console_SdkToolPath)</ExecutablePath>
	<ReferencePath>$(Console_SdkLibPath);$(Console_SdkWindowsMetadataPath)</ReferencePath>
	<LibraryWPath>$(Console_SdkLibPath);$(Console_SdkWindowsMetadataPath)</LibraryWPath>
</PropertyGroup>
		]]
	end

	function suite.onLayout()
		xbox_layoutdir 'testdir'
		prepare()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Gaming.Xbox.Scarlett.x64'">
	<LinkIncremental>true</LinkIncremental>
	<OutDir>bin\Debug\</OutDir>
	<IntDir>obj\Debug\</IntDir>
	<TargetName>MyProject</TargetName>
	<TargetExt>.exe</TargetExt>
	<IncludePath>$(Console_SdkIncludeRoot)</IncludePath>
	<LibraryPath>$(Console_SdkLibPath)</LibraryPath>
	<EmbedManifest>false</EmbedManifest>
	<GenerateManifest>false</GenerateManifest>
	<ExecutablePath>$(Console_SdkRoot)bin;$(Console_SdkToolPath)</ExecutablePath>
	<ReferencePath>$(Console_SdkLibPath);$(Console_SdkWindowsMetadataPath)</ReferencePath>
	<LibraryWPath>$(Console_SdkLibPath);$(Console_SdkWindowsMetadataPath)</LibraryWPath>
	<LayoutDir>testdir</LayoutDir>
</PropertyGroup>
		]]
	end
