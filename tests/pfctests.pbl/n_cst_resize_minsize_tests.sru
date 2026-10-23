//objectcomments Unit tests for the resize service's minimum window size (#47; no database needed)
forward
global type n_cst_resize_minsize_tests from testcase
end type
end forward

global type n_cst_resize_minsize_tests from testcase
event test_off_by_default ( )
event test_minimum_applied ( )
event test_never_lowered ( )
event test_without_minimum ( )
event test_resize_clamped ( )
end type
global n_cst_resize_minsize_tests n_cst_resize_minsize_tests

type prototypes
Function longptr mst_LocalAlloc (ulong aul_flags, longptr al_bytes) Library "kernel32.dll" Alias For "LocalAlloc"
Function longptr mst_LocalFree (longptr al_memory) Library "kernel32.dll" Alias For "LocalFree"
Subroutine mst_CopyFromMemory (ref blob ablb_destination, longptr al_source, longptr al_length) Library "kernel32.dll" Alias For "RtlMoveMemory"
Subroutine mst_CopyToMemory (longptr al_destination, ref blob ablb_source, longptr al_length) Library "kernel32.dll" Alias For "RtlMoveMemory"
Function boolean mst_GetWindowRect (longptr al_hwnd, ref blob ablb_rect) Library "user32.dll" Alias For "GetWindowRect"
Function boolean mst_GetClientRect (longptr al_hwnd, ref blob ablb_rect) Library "user32.dll" Alias For "GetClientRect"
end prototypes

type variables
Protected:
Constant ULong LPTR = 64		// LMEM_FIXED | LMEM_ZEROINIT
Constant Long TOLERANCE = 2	// pixels (rounding of units)

w_pfctest_resize	iw_resize
longptr				il_minmaxinfo
end variables

forward prototypes
protected subroutine of_setmintrack (long al_x, long al_y)
protected subroutine of_getmintrack (ref long al_x, ref long al_y)
protected subroutine of_frame (ref long al_x, ref long al_y)
end prototypes

protected subroutine of_setmintrack (long al_x, long al_y);// A MINMAXINFO whose ptMinTrackSize is (al_x, al_y), as Windows fills it in
blob{40}	lblb_info

BlobEdit(lblb_info, 25, al_x)
BlobEdit(lblb_info, 29, al_y)
mst_CopyToMemory(il_minmaxinfo, lblb_info, 40)
end subroutine

protected subroutine of_getmintrack (ref long al_x, ref long al_y);blob{40}	lblb_info

mst_CopyFromMemory(lblb_info, il_minmaxinfo, 40)
al_x = Long(BlobMid(lblb_info, 25, 4))
al_y = Long(BlobMid(lblb_info, 29, 4))
end subroutine

protected subroutine of_frame (ref long al_x, ref long al_y);// The window's frame, in pixels
blob{16}	lblb_window, lblb_client

mst_GetWindowRect(Handle(iw_resize), lblb_window)
mst_GetClientRect(Handle(iw_resize), lblb_client)
al_x = (Long(BlobMid(lblb_window, 9, 4)) - Long(BlobMid(lblb_window, 1, 4))) - Long(BlobMid(lblb_client, 9, 4))
al_y = (Long(BlobMid(lblb_window, 13, 4)) - Long(BlobMid(lblb_window, 5, 4))) - Long(BlobMid(lblb_client, 13, 4))
end subroutine

event setup;call super::setup;Open(iw_resize)
iw_resize.of_SetResize(True)
il_minmaxinfo = mst_LocalAlloc(LPTR, 40)
end event

event teardown;call super::teardown;If il_minmaxinfo <> 0 Then mst_LocalFree(il_minmaxinfo)
If IsValid(iw_resize) Then Close(iw_resize)
end event

event test_off_by_default();// Without of_SetWindowMinSize(TRUE), the window's minimum size isn't changed
long	ll_x, ll_y

assertFalse("off", iw_resize.inv_resize.of_IsWindowMinSize())
iw_resize.inv_resize.of_SetMinSize(1500, 800)
of_SetMinTrack(100, 100)
iw_resize.Event pfc_GetMinMaxInfo(il_minmaxinfo)
of_GetMinTrack(ll_x, ll_y)
assertEquals("x", 100, ll_x)
assertEquals("y", 100, ll_y)
end event

event test_minimum_applied();// The minimum tracking size is the minimum workspace plus the frame
long	ll_x, ll_y, ll_framex, ll_framey, ll_expectx, ll_expecty

iw_resize.inv_resize.of_SetMinSize(1500, 800)
assertEquals("switch", 1, iw_resize.inv_resize.of_SetWindowMinSize(True))
assertTrue("on", iw_resize.inv_resize.of_IsWindowMinSize())
of_SetMinTrack(100, 100)
iw_resize.Event pfc_GetMinMaxInfo(il_minmaxinfo)
of_GetMinTrack(ll_x, ll_y)
of_Frame(ll_framex, ll_framey)
ll_expectx = UnitsToPixels(1500, XUnitsToPixels!) + ll_framex
ll_expecty = UnitsToPixels(800, YUnitsToPixels!) + ll_framey
assertTrue("x " + String(ll_x) + ", expected " + String(ll_expectx), Abs(ll_x - ll_expectx) <= TOLERANCE)
assertTrue("y " + String(ll_y) + ", expected " + String(ll_expecty), Abs(ll_y - ll_expecty) <= TOLERANCE)
end event

event test_never_lowered();// A larger minimum from Windows is kept
long	ll_x, ll_y

iw_resize.inv_resize.of_SetMinSize(1500, 800)
iw_resize.inv_resize.of_SetWindowMinSize(True)
of_SetMinTrack(5000, 5000)
iw_resize.Event pfc_GetMinMaxInfo(il_minmaxinfo)
of_GetMinTrack(ll_x, ll_y)
assertEquals("x", 5000, ll_x)
assertEquals("y", 5000, ll_y)
end event

event test_without_minimum();// Switched on, but no minimum size set: nothing changes
long	ll_x, ll_y

iw_resize.inv_resize.of_SetWindowMinSize(True)
of_SetMinTrack(100, 100)
iw_resize.Event pfc_GetMinMaxInfo(il_minmaxinfo)
of_GetMinTrack(ll_x, ll_y)
assertEquals("x", 100, ll_x)
assertEquals("y", 100, ll_y)
end event

event test_resize_clamped();// Windows applies the minimum when the window is resized
iw_resize.inv_resize.of_SetMinSize(1500, 800)
iw_resize.inv_resize.of_SetWindowMinSize(True)
iw_resize.Resize(500, 300)
assertTrue("workspace width " + String(iw_resize.WorkSpaceWidth()), iw_resize.WorkSpaceWidth() >= 1500 - 10)
assertTrue("workspace height " + String(iw_resize.WorkSpaceHeight()), iw_resize.WorkSpaceHeight() >= 800 - 10)
end event

on n_cst_resize_minsize_tests.create
call super::create
end on

on n_cst_resize_minsize_tests.destroy
call super::destroy
end on
