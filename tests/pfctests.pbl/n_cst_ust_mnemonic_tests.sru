//objectcomments Unit tests for u_st: Alt and a label's mnemonic move the focus on to the control the label describes (#116)
forward
global type n_cst_ust_mnemonic_tests from testcase
end type
end forward

global type n_cst_ust_mnemonic_tests from testcase
event test_getmnemonic ( )
event test_alt_mnemonic_right ( )
event test_alt_mnemonic_accelerator ( )
event test_alt_mnemonic_below ( )
event test_skips_disabled_invisible_notab ( )
event test_no_target ( )
event test_click_keeps_focus ( )
event test_clickable_keeps_focus ( )
event test_multitable_accelerators ( )
end type
global n_cst_ust_mnemonic_tests n_cst_ust_mnemonic_tests

type prototypes
Function boolean SetForegroundWindow(ulong hwnd) Library "user32.dll"
Subroutine keybd_event(byte bVk, byte bScan, ulong dwFlags, longptr dwExtraInfo) Library "user32.dll"
Function longptr GetForegroundWindow() Library "user32.dll"
Subroutine Sleep(ulong dwMilliseconds) Library "kernel32.dll"
Function ulong GetWindowThreadProcessId(longptr hWnd, ref ulong lpdwProcessId) Library "user32.dll"
Function ulong GetCurrentThreadId() Library "kernel32.dll"
Function boolean AttachThreadInput(ulong idAttach, ulong idAttachTo, boolean fAttach) Library "user32.dll"
end prototypes

type variables
Protected:
// Window messages for a left click
Constant UnsignedInteger WM_LBUTTONDOWN = 513
Constant UnsignedInteger WM_LBUTTONUP = 514
Constant Long MK_LBUTTON = 1
// Keys
Constant Byte VK_MENU = 18	// Alt
Constant Byte VK_N = 78
Constant Byte VK_A = 65
Constant ULong KEYEVENTF_KEYUP = 2

w_pfctest_host				iw_host
singlelineedit				isle_start, isle_right, isle_below, isle_accel
u_pfctest_st_clicks		ist
u_pfctest_st_clickable	ist_clickable
end variables

forward prototypes
protected subroutine of_click (statictext ast)
protected subroutine of_altkey (byte ab_key)
protected function boolean of_hasfocus (dragobject ado)
end prototypes

protected subroutine of_click (statictext ast);// A left click on the label, through its window, as the mouse sends it
Long	ll_pos

ll_pos = 5 * 65536 + 10	// y = 5, x = 10 pixels
Send(Handle(ast), WM_LBUTTONDOWN, MK_LBUTTON, ll_pos)
Send(Handle(ast), WM_LBUTTONUP, 0, ll_pos)
Yield()
end subroutine

protected subroutine of_altkey (byte ab_key);// The user presses Alt and a key, then lets go of the key, then of Alt.
// The keys go to the foreground window, which takes a moment to become the host window.
// Windows only lets a process take the foreground in some cases; attaching to the input of
// the foreground window's thread is one.
Integer	li_try
ULong		lul_process, lul_thread, lul_fgthread

lul_thread = GetCurrentThreadId()
For li_try = 1 To 50
	If GetForegroundWindow() = Handle(iw_host) Then Exit
	lul_fgthread = GetWindowThreadProcessId(GetForegroundWindow(), lul_process)
	If lul_fgthread <> 0 And lul_fgthread <> lul_thread Then
		AttachThreadInput(lul_thread, lul_fgthread, True)
		SetForegroundWindow(Handle(iw_host))
		AttachThreadInput(lul_thread, lul_fgthread, False)
	Else
		SetForegroundWindow(Handle(iw_host))
	End If
	Yield()
	Sleep(20)
Next
assertTrue("the host window is in the foreground", GetForegroundWindow() = Handle(iw_host))
Yield()
keybd_event(VK_MENU, 0, 0, 0)
keybd_event(ab_key, 0, 0, 0)
keybd_event(ab_key, 0, KEYEVENTF_KEYUP, 0)
Yield()
Yield()
keybd_event(VK_MENU, 0, KEYEVENTF_KEYUP, 0)
Yield()
Yield()
end subroutine

protected function boolean of_hasfocus (dragobject ado);GraphicObject	lgo_focus

lgo_focus = GetFocus()
If IsNull(lgo_focus) Or Not IsValid(lgo_focus) Then Return False
Return lgo_focus = ado
end function

event setup;call super::setup;// A visible window (so that controls can have focus):
//	isle_start		where the user is working
//	ist				"Fi&nd what", with isle_right to its right and isle_below below it
//	isle_accel		elsewhere
Open(iw_host)
iw_host.Visible = True
iw_host.OpenUserObject(isle_start, 10, 10)
isle_start.Resize(500, 80)
isle_start.TabOrder = 10
iw_host.OpenUserObject(ist, 10, 200)
ist.Resize(500, 80)
ist.Text = "Fi&nd what"
iw_host.OpenUserObject(isle_right, 600, 200)
isle_right.Resize(500, 80)
isle_right.TabOrder = 20
iw_host.OpenUserObject(isle_below, 10, 400)
isle_below.Resize(500, 80)
isle_below.TabOrder = 30
iw_host.OpenUserObject(isle_accel, 1200, 800)
isle_accel.Resize(500, 80)
isle_accel.TabOrder = 40
SetForegroundWindow(Handle(iw_host))
isle_start.SetFocus()
Yield()
end event

event teardown;call super::teardown;If IsValid(iw_host) Then Close(iw_host)
end event

event test_getmnemonic();// The character after the first single &, in lowercase; && is a literal &
assertEquals("Fi&nd what", "n", ist.of_GetMnemonic())
ist.Text = "&Left:"
assertEquals("&Left:", "l", ist.of_GetMnemonic())
ist.Text = "Fish && &Chips"
assertEquals("Fish && &Chips", "c", ist.of_GetMnemonic())
ist.Text = "A&&B"
assertEquals("A&&B", "", ist.of_GetMnemonic())
ist.Text = "None"
assertEquals("None", "", ist.of_GetMnemonic())
ist.Text = "End&"
assertEquals("End&", "", ist.of_GetMnemonic())
end event

event test_alt_mnemonic_right();// Alt+N moves the focus to the control to the right of the label, not to the label
assertTrue("isle_start has focus first", of_HasFocus(isle_start))
of_AltKey(VK_N)
assertTrue("isle_right has focus", of_HasFocus(isle_right))
assertFalse("the label doesn't keep focus", of_HasFocus(ist))
// getfocus ran (the ancestor's, with the microhelp notification, too); PowerBuilder can
// give the label focus more than once for one Alt+N
assertTrue("getfocus", ist.ii_getfocus >= 1)
end event

event test_alt_mnemonic_accelerator();// The control whose Accelerator is the mnemonic comes before the one to the right
isle_accel.Accelerator = Asc("n")
of_AltKey(VK_N)
assertTrue("isle_accel has focus", of_HasFocus(isle_accel))
end event

event test_alt_mnemonic_below();// With nothing to the right of the label, the control below it
isle_right.Y = 1000
of_AltKey(VK_N)
assertTrue("isle_below has focus", of_HasFocus(isle_below))
end event

event test_skips_disabled_invisible_notab();// Controls that can't take focus are passed over
isle_right.Enabled = False
assertEquals("right disabled", 1, ist.of_FocusMnemonicTarget())
assertTrue("isle_below has focus", of_HasFocus(isle_below))

isle_start.SetFocus()
isle_below.Visible = False
isle_accel.Accelerator = Asc("n")
isle_accel.TabOrder = 0
assertEquals("none left", 0, ist.of_FocusMnemonicTarget())
assertTrue("isle_start keeps focus", of_HasFocus(isle_start))
end event

event test_no_target();// A label without a mnemonic has nothing to move the focus to
ist.Text = "Find what"
assertEquals("no mnemonic", 0, ist.of_FocusMnemonicTarget())
assertTrue("isle_start keeps focus", of_HasFocus(isle_start))
end event

event test_click_keeps_focus();// A click on a label with a mnemonic is still ignored
of_click(ist)
assertTrue("isle_start keeps focus", of_HasFocus(isle_start))
assertEquals("clicked", 0, ist.ii_clicked)
assertEquals("getfocus", 0, ist.ii_getfocus)
end event

event test_clickable_keeps_focus();// A descendant that takes clicks keeps the focus a click gives it, mnemonic or not
// (isle_accel is to its right)
iw_host.OpenUserObject(ist_clickable, 600, 800)
ist_clickable.Resize(500, 80)
ist_clickable.Text = "Click&able"
of_click(ist_clickable)
Yield()
assertEquals("clicked", 1, ist_clickable.ii_clicked)
assertTrue("the label has focus", of_HasFocus(ist_clickable))
end event

event test_multitable_accelerators();// The Multitable service tab page: each label's mnemonic is its list's accelerator.
// lb_keycolumns had k ("&Key Columns" is a radio button's), not the q of "Uni&que Key Column(s)".
u_tabpg_dwproperty_srvmultitable	luo_page

luo_page = Create u_tabpg_dwproperty_srvmultitable
assertEquals("&Table", Asc(luo_page.st_table.of_GetMnemonic()), luo_page.ddlb_table.Accelerator)
assertEquals("Uni&que Key Column(s)", Asc(luo_page.st_keycolumns.of_GetMnemonic()), luo_page.lb_keycolumns.Accelerator)
assertEquals("Updateable &Column(s)", Asc(luo_page.st_updatecolumns.of_GetMnemonic()), luo_page.lb_updatecolumns.Accelerator)
Destroy luo_page
end event

on n_cst_ust_mnemonic_tests.create
call super::create
end on

on n_cst_ust_mnemonic_tests.destroy
call super::destroy
end on
