//objectcomments Unit tests for the split bar's mouse handling (#39; no database needed)
forward
global type n_cst_splitbar_tests from testcase
end type
end forward

global type n_cst_splitbar_tests from testcase
event test_drag_from_elsewhere_ignored ( )
event test_drag_from_bar ( )
event test_button_released_elsewhere ( )
end type
global n_cst_splitbar_tests n_cst_splitbar_tests

type variables
Protected:
// MK_LBUTTON in the flags of pbm_mousemove: the left button is down
Constant UnsignedLong MK_LBUTTON = 1

w_pfctest_host		iw_host
u_st_splitbar		ist_bar
statictext			ist_top
statictext			ist_bottom
end variables

event setup;call super::setup;// A horizontal bar (wider than high) between two controls
Open(iw_host)
iw_host.OpenUserObject(ist_top, 10, 10)
ist_top.Resize(600, 200)
iw_host.OpenUserObject(ist_bar, 10, 220)
iw_host.OpenUserObject(ist_bottom, 10, 250)
ist_bottom.Resize(600, 200)
ist_bar.of_Register(ist_top, ist_bar.ABOVE)
ist_bar.of_Register(ist_bottom, ist_bar.BELOW)
end event

event teardown;call super::teardown;If IsValid(iw_host) Then Close(iw_host)
end event

event test_drag_from_elsewhere_ignored();// The left button was pressed somewhere else and the mouse moves over the bar:
// the bar doesn't move (its lbuttonup would go to the other control).
Integer	li_y

li_y = ist_bar.Y
ist_bar.Event mousemove(MK_LBUTTON, 10, 5)
assertEquals("not moving", ist_bar.of_GetBarColor(), ist_bar.BackColor)
assertEquals("same place", li_y, ist_bar.Y)
end event

event test_drag_from_bar();// Pressed on the bar: moving the mouse moves it (the "moving" color), and releasing
// the button ends the drag.
ist_bar.Event lbuttondown(MK_LBUTTON, 10, 5)
ist_bar.Event mousemove(MK_LBUTTON, 10, 5)
assertEquals("moving", ist_bar.of_GetBarMoveColor(), ist_bar.BackColor)
ist_bar.Event lbuttonup(0, 10, 5)
assertEquals("dropped", ist_bar.of_GetBarColor(), ist_bar.BackColor)
ist_bar.Event mousemove(MK_LBUTTON, 10, 5)
assertEquals("drag over", ist_bar.of_GetBarColor(), ist_bar.BackColor)
end event

event test_button_released_elsewhere();// Pressed on the bar, but the bar missed the button up: once the flags say the
// button is up, moving the mouse no longer moves the bar.
ist_bar.Event lbuttondown(MK_LBUTTON, 10, 5)
ist_bar.Event mousemove(0, 10, 5)
assertEquals("button up", ist_bar.of_GetBarColor(), ist_bar.BackColor)
ist_bar.Event mousemove(MK_LBUTTON, 10, 5)
assertEquals("drag over", ist_bar.of_GetBarColor(), ist_bar.BackColor)
end event

on n_cst_splitbar_tests.create
call super::create
end on

on n_cst_splitbar_tests.destroy
call super::destroy
end on
