//objectcomments Hidden w_master that records the print events, for the message router tests
forward
global type w_pfctest_print from w_master
end type
end forward

global type w_pfctest_print from w_master
integer width = 2400
integer height = 1400
boolean visible = false
string title = "PFC print routing test"
end type
global w_pfctest_print w_pfctest_print

type variables
Public:
// The events in the order they ran, for example "pre,print,post,"
string	is_log
// TRUE: the window's pfc_print and pfc_printimmediate print it themselves (Return 1)
boolean	ib_windowprints
u_pfctest_printdw	idw_print
end variables

forward prototypes
public subroutine of_log (string as_event)
public function integer of_adddatawindow ()
end prototypes

public subroutine of_log (string as_event);is_log += as_event + ","
end subroutine

public function integer of_adddatawindow ();// A datawindow the message router reaches as the last active one
If OpenUserObject(idw_print) <> 1 Then Return -1
This.Event pfc_controlgotfocus(idw_print)
Return 1
end function

event pfc_preprint;call super::pfc_preprint;of_Log("pre")
end event

event pfc_postprint;call super::pfc_postprint;of_Log("post")
end event

event pfc_print;call super::pfc_print;If ib_windowprints Then
	of_Log("window")
	Return 1
End If
Return AncestorReturnValue
end event

event pfc_printimmediate;call super::pfc_printimmediate;If ib_windowprints Then
	of_Log("windowimmediate")
	Return 1
End If
Return AncestorReturnValue
end event

on w_pfctest_print.create
call super::create
end on

on w_pfctest_print.destroy
call super::destroy
end on
