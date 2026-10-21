//objectcomments Unit tests for how the security service identifies control types (no database needed)
forward
global type n_cst_security_controltype_tests from testcase
end type
end forward

global type n_cst_security_controltype_tests from testcase
event test_systemtype_of_descendant ( )
event test_gettype_picturehyperlink ( )
event test_gettype_descendant ( )
event test_gettype_tabbedbar ( )
end type
global n_cst_security_controltype_tests n_cst_security_controltype_tests

type variables
Protected:
w_pfctest_host			iw_host
n_pfctest_security	inv_security
end variables

event setup;call super::setup;Open(iw_host)
inv_security = Create n_pfctest_security
end event

event teardown;call super::teardown;If IsValid(inv_security) Then Destroy inv_security
If IsValid(iw_host) Then Close(iw_host)
end event

event test_systemtype_of_descendant();// The system type is found through the ancestors, so PFC descendants report their base type.
u_cb	lcb

iw_host.OpenUserObject(lcb)
assertEquals("u_cb", "commandbutton", inv_security.of_GetSystemTypeForTest(lcb))
assertEquals("window", "window", inv_security.of_GetSystemTypeForTest(iw_host))
assertEquals("service", "nonvisualobject", inv_security.of_GetSystemTypeForTest(inv_security))
end event

event test_gettype_picturehyperlink();// of_GetType used to assign a PictureHyperLink to a picturelistbox variable, a runtime error.
picturehyperlink	lphl
String				ls_desc

iw_host.OpenUserObject(lphl)
lphl.Tag = "Link"
assertEquals("type", "PictureHyperlink", inv_security.of_GetType(lphl, ls_desc))
assertEquals("description", "Link", ls_desc)
end event

event test_gettype_descendant();u_cb		lcb
String	ls_desc

iw_host.OpenUserObject(lcb)
lcb.Text = "Save"
assertEquals("type", "CommandButton", inv_security.of_GetType(lcb, ls_desc))
assertEquals("description", "Save", ls_desc)
end event

event test_gettype_tabbedbar();// of_GetType used to recognize the MDI tabbed bar only by the name mditbb_1.
TabbedBar	ltb
String		ls_desc

iw_host.OpenUserObject(ltb)
assertEquals("type", "TabbedBar", inv_security.of_GetType(ltb, ls_desc))
end event

on n_cst_security_controltype_tests.create
call super::create
end on

on n_cst_security_controltype_tests.destroy
call super::destroy
end on
