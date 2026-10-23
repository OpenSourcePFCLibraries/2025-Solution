//objectcomments Unit tests for the DataWindow resize service's FIXEDCENTER methods (#48; no database needed)
forward
global type n_cst_dwresize_center_tests from testcase
end type
end forward

global type n_cst_dwresize_center_tests from testcase
event test_fixedcenter ( )
event test_fixedcentertop ( )
event test_fixedcenterbottom ( )
event test_fixedcenterleft ( )
event test_fixedcenterright ( )
event test_fixedright_unchanged ( )
event test_unknown_method ( )
end type
global n_cst_dwresize_center_tests n_cst_dwresize_center_tests

type variables
Protected:
// The DataWindow grows by this much; a centered column moves by half
Constant Integer GROWX = 400
Constant Integer GROWY = 200
Constant Integer TOLERANCE = 2

w_pfctest_host	iw_host
u_dw				idw
end variables

forward prototypes
protected subroutine of_check (string as_method, integer ai_movex, integer ai_movey)
end prototypes

protected subroutine of_check (string as_method, integer ai_movex, integer ai_movey);// Registers the code column with as_method, grows the DataWindow, and checks how far
// the column moved
integer	li_x, li_y, li_dx, li_dy

assertEquals(as_method + " registered", 1, idw.inv_resize.of_Register("code", as_method))
li_x = Integer(idw.Describe("code.X"))
li_y = Integer(idw.Describe("code.Y"))
idw.Resize(idw.Width + GROWX, idw.Height + GROWY)
li_dx = Integer(idw.Describe("code.X")) - li_x
li_dy = Integer(idw.Describe("code.Y")) - li_y
assertTrue(as_method + ": moved right by " + String(li_dx) + ", expected " + String(ai_movex), Abs(li_dx - ai_movex) <= TOLERANCE)
assertTrue(as_method + ": moved down by " + String(li_dy) + ", expected " + String(ai_movey), Abs(li_dy - ai_movey) <= TOLERANCE)
end subroutine

event setup;call super::setup;Open(iw_host)
iw_host.OpenUserObject(idw)
idw.DataObject = "d_pfctest_linkage_master"
idw.Resize(1200, 600)
idw.of_SetResize(True)
end event

event teardown;call super::teardown;If IsValid(iw_host) Then Close(iw_host)
end event

event test_fixedcenter();of_Check(idw.inv_resize.FIXEDCENTER, GROWX / 2, GROWY / 2)
end event

event test_fixedcentertop();of_Check(idw.inv_resize.FIXEDCENTERTOP, GROWX / 2, 0)
end event

event test_fixedcenterbottom();of_Check(idw.inv_resize.FIXEDCENTERBOTTOM, GROWX / 2, GROWY)
end event

event test_fixedcenterleft();of_Check(idw.inv_resize.FIXEDCENTERLEFT, 0, GROWY / 2)
end event

event test_fixedcenterright();of_Check(idw.inv_resize.FIXEDCENTERRIGHT, GROWX, GROWY / 2)
end event

event test_fixedright_unchanged();// The existing methods work as before
of_Check(idw.inv_resize.FIXEDRIGHT, GROWX, 0)
end event

event test_unknown_method();assertEquals("unknown", -1, idw.inv_resize.of_Register("code", "FixedToNowhere"))
end event

on n_cst_dwresize_center_tests.create
call super::create
end on

on n_cst_dwresize_center_tests.destroy
call super::destroy
end on
