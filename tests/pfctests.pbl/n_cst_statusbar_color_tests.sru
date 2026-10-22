//objectcomments Unit tests for the status bar background and text colors (no database needed)
forward
global type n_cst_statusbar_color_tests from testcase
end type
end forward

global type n_cst_statusbar_color_tests from testcase
event test_default_colors ( )
event test_background_color ( )
event test_text_color ( )
event test_colors_set_before_open ( )
event test_invalid_colors ( )
end type
global n_cst_statusbar_color_tests n_cst_statusbar_color_tests

type variables
Protected:
Constant Long WINDOWTEXT = 33554432
Constant Long LIGHTGRAY = 13421772	// #CCCCCC
Constant Long WHITE = 16777215

w_pfctest_frame		iw_frame
n_pfctest_statusbar	inv_statusbar
end variables

forward prototypes
protected function boolean of_openframe ()
protected function boolean of_openstatusbar ()
protected function long of_buttonface ()
protected function string of_color (string as_property)
end prototypes

protected function boolean of_openframe ();// Opens the hidden frame with the test status bar service, showing the timer and the progress bar.
If Not assertEquals("Open frame", 1, Open(iw_frame)) Then Return False

inv_statusbar = Create n_pfctest_statusbar
inv_statusbar.of_SetRequestor(iw_frame)
iw_frame.inv_statusbar = inv_statusbar
inv_statusbar.of_SetTimer(True)
inv_statusbar.of_SetBar(True)
Return True
end function

protected function boolean of_openstatusbar ();// Opens the status bar window.
inv_statusbar.of_Open(True)
Return assertTrue("status bar window open", IsValid(inv_statusbar.of_GetWindowForTest()))
end function

protected function long of_buttonface ();// The color pfc_w_statusbar uses by default: the system ButtonFace color (no theme is applied).
String	ls_rgb
Integer	li_red, li_green, li_blue, li_pos

RegistryGet("hkey_current_user\control panel\colors", "buttonface", ls_rgb)
If IsNull(ls_rgb) Or Len(ls_rgb) = 0 Then Return 78682240

li_pos = Pos(ls_rgb, " ")
li_red = Integer(Left(ls_rgb, li_pos - 1))
ls_rgb = Mid(ls_rgb, li_pos + 1)
li_pos = Pos(ls_rgb, " ")
li_green = Integer(Left(ls_rgb, li_pos - 1))
li_blue = Integer(Mid(ls_rgb, li_pos + 1))
Return RGB(li_red, li_green, li_blue)
end function

protected function string of_color (string as_property);// A property of the status bar DataWindow, for example "pfc_timer.Color".
Return inv_statusbar.of_GetWindowForTest().dw_statusbar.Describe(as_property)
end function

event test_default_colors();// Without colors from the application, the status bar keeps the system colors
// (it used to be gray, the service's default, whatever the system colors).
If Not of_OpenFrame() Then Return
If Not of_OpenStatusBar() Then Return

assertEquals("window background", of_ButtonFace(), inv_statusbar.of_GetWindowForTest().BackColor)
assertEquals("timer background", String(of_ButtonFace()), of_Color("pfc_timer.Background.Color"))
assertEquals("timer text", String(WINDOWTEXT), of_Color("pfc_timer.Color"))
end event

event test_background_color();If Not of_OpenFrame() Then Return
If Not of_OpenStatusBar() Then Return

assertEquals("of_SetBackgroundColor", 1, inv_statusbar.of_SetBackgroundColor(LIGHTGRAY))
assertEquals("window background", LIGHTGRAY, inv_statusbar.of_GetWindowForTest().BackColor)
assertEquals("timer background", String(LIGHTGRAY), of_Color("pfc_timer.Background.Color"))
end event

event test_text_color();// The text color applies to the status bar text, but not to the progress bar text,
// which has its own color (of_SetBarTextColor, black by default).
If Not of_OpenFrame() Then Return
If Not of_OpenStatusBar() Then Return

assertEquals("of_SetTextColor", 1, inv_statusbar.of_SetTextColor(WHITE))
assertEquals("timer text", String(WHITE), of_Color("pfc_timer.Color"))
assertEquals("progress bar text", "0", of_Color("pfc_progress_border.Color"))
end event

event test_colors_set_before_open();// Colors set while setting up the service are applied when the status bar opens.
If Not of_OpenFrame() Then Return

assertEquals("of_SetBackgroundColor", 1, inv_statusbar.of_SetBackgroundColor(LIGHTGRAY))
assertEquals("of_SetTextColor", 1, inv_statusbar.of_SetTextColor(WHITE))
If Not of_OpenStatusBar() Then Return

assertEquals("window background", LIGHTGRAY, inv_statusbar.of_GetWindowForTest().BackColor)
assertEquals("timer background", String(LIGHTGRAY), of_Color("pfc_timer.Background.Color"))
assertEquals("timer text", String(WHITE), of_Color("pfc_timer.Color"))
end event

event test_invalid_colors();Long	ll_null

If Not of_OpenFrame() Then Return
SetNull(ll_null)

assertEquals("negative background", -1, inv_statusbar.of_SetBackgroundColor(-1))
assertEquals("null background", -1, inv_statusbar.of_SetBackgroundColor(ll_null))
assertEquals("negative text", -1, inv_statusbar.of_SetTextColor(-1))
assertEquals("null text", -1, inv_statusbar.of_SetTextColor(ll_null))
end event

event teardown;call super::teardown;If IsValid(iw_frame) Then Close(iw_frame)
end event

on n_cst_statusbar_color_tests.create
call super::create
end on

on n_cst_statusbar_color_tests.destroy
call super::destroy
end on
