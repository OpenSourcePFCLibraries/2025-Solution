//objectcomments u_dw whose database work is recorded by inv_recorder (pbunitmocks) and, by default, not sent
forward
global type u_pfctest_spydw from u_dw
end type
end forward

global type u_pfctest_spydw from u_dw
end type
global u_pfctest_spydw u_pfctest_spydw

type variables
Public:
// Several spies can share one recorder, to see the order of statements across DataWindows.
n_pbunit_dwrecorder	inv_recorder
end variables

event constructor;call super::constructor;inv_recorder = Create n_pbunit_dwrecorder
end event

event destructor;call super::destructor;If IsValid(inv_recorder) Then Destroy inv_recorder
end event

event retrievestart;call super::retrievestart;Return inv_recorder.of_OnRetrieveStart()
end event

event retrieveend;call super::retrieveend;inv_recorder.of_OnRetrieveEnd(This)
end event

event sqlpreview;call super::sqlpreview;// u_dw skips (2) the statement types an update leaves out (of_Update with inserts,
// updates or deletes off, as the linkage service's two-pass styles do): respect that.
If AncestorReturnValue = 1 Or AncestorReturnValue = 2 Then Return AncestorReturnValue
Return inv_recorder.of_OnSqlPreview(sqltype, sqlsyntax, row)
end event

event updatestart;call super::updatestart;Return inv_recorder.of_OnUpdateStart()
end event

event dberror;// Overrides u_dw's message box: record the error so a test can report it.
Return inv_recorder.of_OnDbError(sqldbcode, sqlerrtext)
end event

on u_pfctest_spydw.create
call super::create
end on

on u_pfctest_spydw.destroy
call super::destroy
end on
