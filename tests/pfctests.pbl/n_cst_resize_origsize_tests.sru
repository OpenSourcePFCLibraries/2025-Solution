//objectcomments Unit tests for the window resize service's original size (#44; no database needed)
forward
global type n_cst_resize_origsize_tests from testcase
end type
end forward

global type n_cst_resize_origsize_tests from testcase
event test_at_open ( )
event test_opened_smaller ( )
event test_opened_larger ( )
event test_inherited_size ( )
event test_setresize ( )
end type
global n_cst_resize_origsize_tests n_cst_resize_origsize_tests

type variables
Protected:
// The original size may differ from the expected one by the rounding of pixels to units
Constant Integer TOLERANCE = 2

w_pfctest_resize			iw_resize
w_pfctest_resize_child	iw_child
end variables

forward prototypes
protected subroutine of_designworkspace (window aw_window, ref integer ai_width, ref integer ai_height)
protected subroutine of_assertsize (string as_what, w_pfctest_resize aw_window, integer ai_width, integer ai_height)
end prototypes

protected subroutine of_designworkspace (window aw_window, ref integer ai_width, ref integer ai_height);// The workspace at the design size (2000 x 1200), as in the window painter: resize to
// it, measure, and put the window back as it was
integer	li_width, li_height

li_width = aw_window.Width
li_height = aw_window.Height
aw_window.Resize(2000, 1200)
ai_width = aw_window.WorkSpaceWidth()
ai_height = aw_window.WorkSpaceHeight()
aw_window.Resize(li_width, li_height)
end subroutine

protected subroutine of_assertsize (string as_what, w_pfctest_resize aw_window, integer ai_width, integer ai_height);// of_GetOrigSize gives the design-time workspace
integer	li_width, li_height

aw_window.of_GetOrigSizeForTest(li_width, li_height)
assertTrue(as_what + ": width " + String(li_width) + ", expected " + String(ai_width), Abs(li_width - ai_width) <= TOLERANCE)
assertTrue(as_what + ": height " + String(li_height) + ", expected " + String(ai_height), Abs(li_height - ai_height) <= TOLERANCE)
end subroutine

event setup;call super::setup;Open(iw_resize)
end event

event teardown;call super::teardown;If IsValid(iw_resize) Then Close(iw_resize)
If IsValid(iw_child) Then Close(iw_child)
end event

event test_at_open();// Where of_SetResize is usually called: while the window opens, its workspace is
// larger than at design time (Windows makes the window a little larger)
integer	li_width, li_height, li_origwidth, li_origheight, li_openwidth

// Measured first, before the window is resized
li_openwidth = iw_resize.WorkSpaceWidth()
iw_resize.of_GetOrigSizeForTest(li_origwidth, li_origheight)
of_DesignWorkspace(iw_resize, li_width, li_height)
assertTrue("the workspace at open differs: " + String(li_openwidth) + " vs " + String(li_width), li_openwidth <> li_width)
assertTrue("width " + String(li_origwidth) + ", expected " + String(li_width), Abs(li_origwidth - li_width) <= TOLERANCE)
assertTrue("height " + String(li_origheight) + ", expected " + String(li_height), Abs(li_origheight - li_height) <= TOLERANCE)
end event

event test_opened_smaller();// PowerBuilder opens a sheet smaller when it doesn't fit in the frame
integer	li_width, li_height

of_DesignWorkspace(iw_resize, li_width, li_height)
iw_resize.Resize(1000, 600)
of_AssertSize("smaller", iw_resize, li_width, li_height)
end event

event test_opened_larger();// Opened larger, for example maximized
integer	li_width, li_height

of_DesignWorkspace(iw_resize, li_width, li_height)
iw_resize.Resize(3000, 2000)
of_AssertSize("larger", iw_resize, li_width, li_height)
end event

event test_inherited_size();// A descendant that doesn't set a size has its ancestor's
integer	li_width, li_height

Open(iw_child)
of_DesignWorkspace(iw_child, li_width, li_height)
iw_child.Resize(1000, 600)
of_AssertSize("inherited", iw_child, li_width, li_height)
end event

event test_setresize();// of_SetResize starts the service (it has no getter for the size)
iw_resize.Resize(1000, 600)
assertEquals("start", 1, iw_resize.of_SetResize(True))
assertTrue("service", IsValid(iw_resize.inv_resize))
end event

on n_cst_resize_origsize_tests.create
call super::create
end on

on n_cst_resize_origsize_tests.destroy
call super::destroy
end on
