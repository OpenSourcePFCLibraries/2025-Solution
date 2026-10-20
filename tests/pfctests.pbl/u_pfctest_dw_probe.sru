//objectcomments u_dw that counts Retrieve calls and cancels them, so tests need no database
forward
global type u_pfctest_dw_probe from u_dw
end type
end forward

global type u_pfctest_dw_probe from u_dw
end type
global u_pfctest_dw_probe u_pfctest_dw_probe

type variables
Public:
Long		il_retrievecount
Long		il_dberrorcount
String	is_lastdberror
end variables

event retrievestart;call super::retrievestart;// Count the attempt, then return 1 so the retrieval is not performed.
il_retrievecount ++
Return 1
end event

event dberror;// Overrides the PFC message box: record the error so a test can report it.
il_dberrorcount ++
is_lastdberror = String(sqldbcode) + " " + sqlerrtext
Return 1
end event

on u_pfctest_dw_probe.create
call super::create
end on

on u_pfctest_dw_probe.destroy
call super::destroy
end on
