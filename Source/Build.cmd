@echo off

setlocal EnableDelayedExpansion

pushd "%~dp0"


echo ************************************
echo ***** Determine version number *****
echo ************************************
if [%1]==[] (
	Versionator -v>version.temp || exit 1
	set /p VERSION=<version.temp
	if exist version.temp del version.temp
) else (
	set VERSION=%1
)
echo Version: %VERSION%
echo:


if exist Installed.dog (
	echo ******************************************
	echo ***** Installing packages from Jones *****
	echo ******************************************
	dog install || exit 1
	echo:
)


echo *************************************
echo ***** Remove old NuGet packages *****
echo *************************************
ls . \.nupkg$ -rn | bin
echo:


if exist Build_Before.cmd (
	echo ***********************************
	echo ***** Running prebuild script *****
	echo ***********************************
	call Build_Before.cmd || exit 1
	echo:
)


echo *****************************
echo ***** Building solution *****
echo *****************************
dotnet build -p:Version=%VERSION% --force -v quiet --nologo || exit 1
echo:


if exist Build_After.cmd (
	echo ************************************
	echo ***** Running postbuild script *****
	echo ************************************
	call Build_After.cmd || exit 1
	echo:
)


if exist Applications.txt (
	@REM Each line specify a target on the form:
	@REM   PROJECT EXECUTABLE RID
	@REM Example: PackageDog dog win-x64
	echo ***********************************
	echo ***** Publishing applications *****
	echo ***********************************
	if exist PublishingFolder rd /S /Q PublishingFolder
	for /F "tokens=1-3" %%A in (Applications.txt) do (
		echo Publishing %%A as executable %%B for %%C...
		dotnet publish %%A\%%A.csproj --nologo -r %%C --self-contained false -p:EnableCompressionInSingleFile=false -p:PublishSingleFile=false -p:PublishReadyToRun=false -p:Version=%VERSION% -c Debug -o PublishingFolder\%%B\%%C
	)
	echo:
)


REM This step broke after the update to .NET 6.0 so disabled it :(
REM echo *********************************
REM echo ***** Clearing Nuget caches *****
REM echo *********************************
REM When building locally the NuGet cache must be cleared for Visual Studio to actually fetch the new version from the
REM local package repo.
REM dotnet nuget locals global-packages --clear
REM echo:


echo ************************************************************************
echo ***** Pushing created nuget packages (only pushes on build server) *****
echo ************************************************************************
for /r . %%p in (*.nupkg) do (
	echo Pushing '%%p'...
	if defined CI (
		dotnet nuget push %%p -s Artifactory || exit 1
	) else (
		echo %%p>__file_a
		
		li "([^\\]+)\.\d+\.\d+\.\d+" __file_a -hm>__file_b
		set /p PACKAGE_NAME=<__file_b
		
		li "[^\\]+\.(\d+\.\d+\.\d+)" __file_a -hm>__file_c
		set /p PACKAGE_VERSION=<__file_c
		
		nuget delete !PACKAGE_NAME! !PACKAGE_VERSION! -Source c:\LocalNugetRepository\ -NonInteractive
		nuget add %%p -Source c:\LocalNugetRepository\
	)
	echo:
)
if exist __file_a del __file_a
if exist __file_b del __file_b
if exist __file_c del __file_c
echo:


if exist Contents.dog (
	echo *******************************
	echo ***** Publishing to Jones *****
	echo *******************************
	if defined CI (
		dog publish || exit 1
	) else (
		dog publish -p || exit 1
	)
	echo:
)

echo ********************
echo ***** All done *****
echo ********************
echo Version: %VERSION%
