//objectcomments Unit tests for the position of the status bar window over the MicroHelp bar (#45; no database needed)
forward
global type n_cst_statusbar_position_tests from testcase
end type
end forward

global type n_cst_statusbar_position_tests from testcase
event test_over_microhelp ( )
event test_after_resize ( )
event test_narrow_frame ( )
end type
global n_cst_statusbar_position_tests n_cst_statusbar_position_tests

type prototypes
Function boolean sbt_GetWindowRect (longptr al_hwnd, ref blob ablb_rect) Library "user32.dll" Alias For "GetWindowRect"
Function boolean sbt_GetClientRect (longptr al_hwnd, ref blob ablb_rect) Library "user32.dll" Alias For "GetClientRect"
Function boolean sbt_ClientToScreen (longptr al_hwnd, ref blob ablb_point) Library "user32.dll" Alias For "ClientToScreen"
end prototypes

type variables
Protected:
// Pixels the positions may differ by (rounding of units to pixels)
Constant Long TOLERANCE = 3

w_pfctest_frame		iw_frame
n_pfctest_statusbar	inv_statusbar
end variables

forward prototypes
protected function boolean of_open ()
protected function boolean of_openstatusbar ()
protected subroutine of_assertposition (string as_what)
end prototypes

protected function boolean of_open ();// The hidden frame and its status bar window
If Not assertEquals("Open frame", 1, Open(iw_frame)) Then Return False
inv_statusbar = Create n_pfctest_statusbar
inv_statusbar.of_SetRequestor(iw_frame)
iw_frame.inv_statusbar = inv_statusbar
inv_statusbar.of_SetTimer(True)
Return True
end function

protected function boolean of_openstatusbar ();// The status bar window positions itself when it opens
inv_statusbar.of_Open(True)
Return assertTrue("status bar window open", IsValid(inv_statusbar.of_GetWindowForTest()))
end function

protected subroutine of_assertposition (string as_what);// The status bar window is centered in the MicroHelp bar, at the bottom of the frame's
// client area, at its right end (12 units from it), in screen pixels
w_statusbar	lw_bar
blob{16}		lblb_client, lblb_bar
blob{8}		lblb_point
long			ll_clientleft, ll_clientright, ll_clientbottom, ll_barleft, ll_bartop, ll_barright
long			ll_microhelp, ll_margin, ll_barbottom, ll_expectedtop

lw_bar = inv_statusbar.of_GetWindowForTest()
sbt_GetClientRect(Handle(iw_frame), lblb_client)
sbt_ClientToScreen(Handle(iw_frame), lblb_point)
ll_clientleft = Long(BlobMid(lblb_point, 1, 4))
ll_clientright = ll_clientleft + Long(BlobMid(lblb_client, 9, 4))
ll_clientbottom = Long(BlobMid(lblb_point, 5, 4)) + Long(BlobMid(lblb_client, 13, 4))
sbt_GetWindowRect(Handle(lw_bar), lblb_bar)
ll_barleft = Long(BlobMid(lblb_bar, 1, 4))
ll_bartop = Long(BlobMid(lblb_bar, 5, 4))
ll_barright = Long(BlobMid(lblb_bar, 9, 4))
ll_barbottom = Long(BlobMid(lblb_bar, 13, 4))
ll_microhelp = UnitsToPixels(iw_frame.mdi_1.MicroHelpHeight, YUnitsToPixels!)
ll_margin = UnitsToPixels(12, XUnitsToPixels!)
ll_expectedtop = ll_clientbottom - ll_microhelp
If ll_barbottom - ll_bartop < ll_microhelp Then ll_expectedtop += (ll_microhelp - (ll_barbottom - ll_bartop)) / 2

assertTrue(as_what + ": top " + String(ll_bartop) + ", centered in the MicroHelp bar " + String(ll_expectedtop), &
	Abs(ll_bartop - ll_expectedtop) <= TOLERANCE)
assertTrue(as_what + ": inside the MicroHelp bar", ll_bartop >= ll_clientbottom - ll_microhelp And ll_barbottom <= ll_clientbottom)
assertTrue(as_what + ": right " + String(ll_barright) + ", client right less the margin " + String(ll_clientright - ll_margin), &
	Abs(ll_barright - (ll_clientright - ll_margin)) <= TOLERANCE)
assertTrue(as_what + ": left " + String(ll_barleft) + " inside the frame from " + String(ll_clientleft), ll_barleft >= ll_clientleft)
end subroutine

event teardown;call super::teardown;If IsValid(iw_frame) Then Close(iw_frame)
If IsValid(inv_statusbar) Then Destroy inv_statusbar
end event

event test_over_microhelp();If Not of_Open() Then Return
If Not of_OpenStatusBar() Then Return
of_AssertPosition("at open")
end event

event test_after_resize();// Another position and size of the frame
If Not of_Open() Then Return
iw_frame.Move(200, 150)
iw_frame.Resize(4000, 2000)
If Not of_OpenStatusBar() Then Return
of_AssertPosition("moved and resized")
end event

event test_narrow_frame();// A frame narrower than the status bar: the status bar is as wide as the frame
w_statusbar	lw_bar
blob{16}		lblb_client, lblb_bar
blob{8}		lblb_point
long			ll_clientleft, ll_clientright

If Not of_Open() Then Return
iw_frame.Resize(800, 1600)
If Not of_OpenStatusBar() Then Return
lw_bar = inv_statusbar.of_GetWindowForTest()
assertTrue("narrower than the status bar", iw_frame.WorkSpaceWidth() < 1500)
sbt_GetClientRect(Handle(iw_frame), lblb_client)
sbt_ClientToScreen(Handle(iw_frame), lblb_point)
ll_clientleft = Long(BlobMid(lblb_point, 1, 4))
ll_clientright = ll_clientleft + Long(BlobMid(lblb_client, 9, 4))
sbt_GetWindowRect(Handle(lw_bar), lblb_bar)
assertTrue("left inside", Long(BlobMid(lblb_bar, 1, 4)) >= ll_clientleft)
assertTrue("right inside", Long(BlobMid(lblb_bar, 9, 4)) <= ll_clientright)
end event

on n_cst_statusbar_position_tests.create
call super::create
end on

on n_cst_statusbar_position_tests.destroy
call super::destroy
end on
