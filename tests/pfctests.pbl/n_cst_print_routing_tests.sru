//objectcomments Unit tests for the routing of pfc_print and pfc_printimmediate (#38; no printer needed)
forward
global type n_cst_print_routing_tests from testcase
end type
end forward

global type n_cst_print_routing_tests from testcase
event test_print_reaches_datawindow ( )
event test_printimmediate_reaches_datawindow ( )
event test_window_that_prints ( )
event test_no_datawindow ( )
end type
global n_cst_print_routing_tests n_cst_print_routing_tests

type variables
Protected:
w_pfctest_print	iw_print
end variables

forward prototypes
protected subroutine of_yield ()
end prototypes

protected subroutine of_yield ();// Lets the posted pfc_postprint run
Integer	li_idx

For li_idx = 1 To 5
	Yield()
Next
end subroutine

event setup;call super::setup;Open(iw_print)
end event

event teardown;call super::teardown;If IsValid(iw_print) Then Close(iw_print)
end event

event test_print_reaches_datawindow();// The menu's Print (pfc_print through the message router) prints the datawindow,
// between the window's pfc_preprint and pfc_postprint.
If Not assertEquals("datawindow", 1, iw_print.of_AddDataWindow()) Then Return
assertEquals("router", 1, iw_print.Event pfc_messagerouter("pfc_print"))
of_Yield()
assertEquals("events", "pre,print,post,", iw_print.is_log)
end event

event test_printimmediate_reaches_datawindow();If Not assertEquals("datawindow", 1, iw_print.of_AddDataWindow()) Then Return
assertEquals("router", 1, iw_print.Event pfc_messagerouter("pfc_printimmediate"))
of_Yield()
assertEquals("events", "pre,printimmediate,post,", iw_print.is_log)
end event

event test_window_that_prints();// A window whose pfc_print prints and returns 1 keeps the message: the datawindow
// doesn't print too.
iw_print.ib_windowprints = True
If Not assertEquals("datawindow", 1, iw_print.of_AddDataWindow()) Then Return
assertEquals("print", 1, iw_print.Event pfc_messagerouter("pfc_print"))
assertEquals("print immediate", 1, iw_print.Event pfc_messagerouter("pfc_printimmediate"))
of_Yield()
assertEquals("events", "pre,window,pre,windowimmediate,post,post,", iw_print.is_log)
end event

event test_no_datawindow();// Without a datawindow nothing prints, and the router doesn't report success.
assertTrue("router", iw_print.Event pfc_messagerouter("pfc_print") <> 1)
of_Yield()
assertEquals("events", "pre,post,", iw_print.is_log)
end event

on n_cst_print_routing_tests.create
call super::create
end on

on n_cst_print_routing_tests.destroy
call super::destroy
end on
