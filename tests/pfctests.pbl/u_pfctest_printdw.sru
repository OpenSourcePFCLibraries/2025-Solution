//objectcomments u_dw whose print events record that they ran instead of printing, for the message router tests
forward
global type u_pfctest_printdw from u_dw
end type
end forward

global type u_pfctest_printdw from u_dw
end type
global u_pfctest_printdw u_pfctest_printdw

event pfc_print;// Overrides the printing: record it in the window's log (w_pfctest_print)
GetParent().Dynamic of_Log("print")
Return 1
end event

event pfc_printimmediate;// Overrides the printing: record it in the window's log (w_pfctest_print)
GetParent().Dynamic of_Log("printimmediate")
Return 1
end event

on u_pfctest_printdw.create
call super::create
end on

on u_pfctest_printdw.destroy
call super::destroy
end on
