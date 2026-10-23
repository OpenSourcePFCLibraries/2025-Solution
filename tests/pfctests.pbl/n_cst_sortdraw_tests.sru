//objectcomments Unit tests for customizing and extending the sort order indicator service (#46; no database needed)
forward
global type n_cst_sortdraw_tests from testcase
end type
end forward

global type n_cst_sortdraw_tests from testcase
event test_getsortdraw ( )
event test_colors_and_alignment ( )
event test_descendant ( )
end type
global n_cst_sortdraw_tests n_cst_sortdraw_tests

type variables
Protected:
w_pfctest_host	iw_host
u_dw				idw
end variables

event setup;call super::setup;Open(iw_host)
iw_host.OpenUserObject(idw)
idw.DataObject = "d_pfctest_linkage_master"
idw.of_SetSort(True)
end event

event teardown;call super::teardown;If IsValid(iw_host) Then Close(iw_host)
end event

event test_getsortdraw();// The sort service gives access to its sort order indicator service, which exists
// while column header sorting is on
assertFalse("before", IsValid(idw.inv_sort.of_GetSortDraw()))
idw.inv_sort.of_SetColumnHeader(True)
assertTrue("column header sorting", IsValid(idw.inv_sort.of_GetSortDraw()))
idw.inv_sort.of_SetColumnHeader(False)
assertFalse("after", IsValid(idw.inv_sort.of_GetSortDraw()))
end event

event test_colors_and_alignment();// An application can set the colors and the alignment (they were protected)
n_cst_dwsrv_sortdraw	lnv_sortdraw

idw.inv_sort.of_SetColumnHeader(True)
lnv_sortdraw = idw.inv_sort.of_GetSortDraw()
If Not assertTrue("sort draw", IsValid(lnv_sortdraw)) Then Return
lnv_sortdraw.of_SetColorLinePrimary(RGB(255, 0, 0))
lnv_sortdraw.of_SetColorLineSecondary(RGB(0, 255, 0))
lnv_sortdraw.of_SetColorLineBackground(RGB(0, 0, 255))
lnv_sortdraw.of_SetAlignment(lnv_sortdraw.RIGHT)
assertEquals("primary", RGB(255, 0, 0), lnv_sortdraw.of_GetColorLinePrimary())
assertEquals("secondary", RGB(0, 255, 0), lnv_sortdraw.of_GetColorLineSecondary())
assertEquals("background", RGB(0, 0, 255), lnv_sortdraw.of_GetColorLineBackground())
assertEquals("alignment", lnv_sortdraw.RIGHT, lnv_sortdraw.of_GetAlignment())
end event

event test_descendant();// A descendant can use the instance variables and override the drawing functions
// (they were private: n_pfctest_sortdraw didn't compile)
n_pfctest_sortdraw	lnv_sortdraw

lnv_sortdraw = Create n_pfctest_sortdraw
lnv_sortdraw.of_SetRequestor(idw)
lnv_sortdraw.of_SetColorLinePrimary(RGB(255, 0, 0))
assertEquals("protected variable", RGB(255, 0, 0), lnv_sortdraw.of_GetPrimaryColorForTest())
assertEquals("band", "foreground", lnv_sortdraw.of_GetBandForTest())
lnv_sortdraw.of_DrawAscendingForTest()
assertTrue("overridden function", lnv_sortdraw.ib_drewascending)
Destroy lnv_sortdraw
end event

on n_cst_sortdraw_tests.create
call super::create
end on

on n_cst_sortdraw_tests.destroy
call super::destroy
end on
