//objectcomments Unit tests for the Windows version that the environment service reports (#98; no database needed)
forward
global type n_cst_environment_tests from testcase
end type
end forward

global type n_cst_environment_tests from testcase
event test_build_number ( )
event test_version_description ( )
end type
global n_cst_environment_tests n_cst_environment_tests

forward prototypes
protected function string of_property (string as_name)
protected function long of_registrybuild ()
end prototypes

protected function string of_property (string as_name);// One of the properties that of_ListProperties lists
n_cst_environment	lnv_env
string	ls_names[], ls_values[]
long	ll_count, ll_i

ll_count = lnv_env.of_ListProperties(ls_names, ls_values)
For ll_i = 1 To ll_count
	If ls_names[ll_i] = as_name Then Return ls_values[ll_i]
Next
Return ""
end function

protected function long of_registrybuild ();// The build number Windows keeps in the registry, independently of the version APIs
string	ls_build

RegistryGet("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion", "CurrentBuildNumber", RegString!, ls_build)
Return Long(ls_build)
end function

event test_build_number();// The service reports the running system's build, not the one Windows gives to
// applications without a manifest (6.2, build 9200)
long	ll_build

ll_build = of_RegistryBuild()
assertTrue("the registry has the build number", ll_build > 0)
assertEquals("build number", String(ll_build), of_Property("OS Build Number"))
If ll_build >= 10240 Then
	assertEquals("major version", "10", of_Property("OS Major Version Number"))
End If
end event

event test_version_description();// Windows 10 and 11 are both version 10.0; the build number tells them apart
long	ll_build
string	ls_desc

ll_build = of_RegistryBuild()
ls_desc = of_Property("OS Version Description")
If ll_build < 10240 Then Return	// older than Windows 10: nothing to compare with

If Pos(of_Property("Product Type"), "0x0001") = 1 Then
	// A workstation
	If ll_build >= 22000 Then
		assertEquals("version description", "Windows 11", ls_desc)
	Else
		assertEquals("version description", "Windows 10", ls_desc)
	End If
Else
	assertTrue("a Windows Server version", Pos(ls_desc, "Windows Server 20") = 1)
End If
end event

on n_cst_environment_tests.create
call super::create
end on

on n_cst_environment_tests.destroy
call super::destroy
end on
