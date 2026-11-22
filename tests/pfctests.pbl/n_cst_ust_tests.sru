//objectcomments Unit tests for u_st: enabled, so themes don't draw it grey, but ignores clicks (#116)
forward
global type n_cst_ust_tests from testcase
end type
end forward

global type n_cst_ust_tests from testcase
event test_enabled ( )
event test_click_keeps_focus ( )
event test_override_takes_clicks ( )
event test_disabled_still_possible ( )
end type
global n_cst_ust_tests n_cst_ust_tests

type prototypes
Function boolean SetForegroundWindow(ulong hwnd) Library "user32.dll"
end prototypes

type variables
Protected:
// Window messages for a left click
Constant UnsignedInteger WM_LBUTTONDOWN = 513
Constant UnsignedInteger WM_LBUTTONUP = 514
Constant Long MK_LBUTTON = 1

w_pfctest_host				iw_host
singlelineedit				isle
u_pfctest_st_clicks		ist
u_pfctest_st_clickable	ist_clickable
end variables

forward prototypes
protected subroutine of_click (statictext ast)
protected function boolean of_slehasfocus ()
end prototypes

protected subroutine of_click (statictext ast);// A left click on the label, through its window, as the mouse sends it
Long	ll_pos

ll_pos = 5 * 65536 + 10	// y = 5, x = 10 pixels
Send(Handle(ast), WM_LBUTTONDOWN, MK_LBUTTON, ll_pos)
Send(Handle(ast), WM_LBUTTONUP, 0, ll_pos)
Yield()
end subroutine

protected function boolean of_slehasfocus ();GraphicObject	lgo_focus

lgo_focus = GetFocus()
If IsNull(lgo_focus) Or Not IsValid(lgo_focus) Then Return False
Return lgo_focus = isle
end function

event setup;call super::setup;// A visible window (so that controls can have focus) with an edit field and two labels
Open(iw_host)
iw_host.Visible = True
iw_host.OpenUserObject(isle, 10, 10)
isle.Resize(600, 80)
iw_host.OpenUserObject(ist, 10, 200)
ist.Resize(600, 80)
ist.Text = "Label"
iw_host.OpenUserObject(ist_clickable, 10, 300)
ist_clickable.Resize(600, 80)
ist_clickable.Text = "Clickable"
SetForegroundWindow(Handle(iw_host))
isle.SetFocus()
Yield()
end event

event teardown;call super::teardown;If IsValid(iw_host) Then Close(iw_host)
end event

event test_enabled();// Created enabled: themes draw disabled labels grey (#116)
u_st	lst

assertTrue("u_st", ist.Enabled)
iw_host.OpenUserObject(lst, 10, 400)
assertTrue("new u_st", lst.Enabled)
iw_host.CloseUserObject(lst)
end event

event test_click_keeps_focus();// A click on a label leaves the focus where it was, and clicked doesn't occur
assertTrue("edit field has focus first", of_SleHasFocus())
of_click(ist)
assertTrue("edit field keeps focus", of_SleHasFocus())
assertEquals("clicked", 0, ist.ii_clicked)
assertEquals("getfocus", 0, ist.ii_getfocus)
end event

event test_override_takes_clicks();// A descendant that overrides lbuttondown gets clicks (and the label takes focus)
of_click(ist_clickable)
assertEquals("clicked", 1, ist_clickable.ii_clicked)
assertEquals("getfocus", 1, ist_clickable.ii_getfocus)
assertFalse("edit field lost focus", of_SleHasFocus())
end event

event test_disabled_still_possible();// A label disabled on purpose stays disabled, and a click on it does nothing
ist.Enabled = False
assertFalse("disabled", ist.Enabled)
of_click(ist)
assertTrue("edit field keeps focus", of_SleHasFocus())
assertEquals("getfocus", 0, ist.ii_getfocus)
end event

on n_cst_ust_tests.create
call super::create
end on

on n_cst_ust_tests.destroy
call super::destroy
end on
