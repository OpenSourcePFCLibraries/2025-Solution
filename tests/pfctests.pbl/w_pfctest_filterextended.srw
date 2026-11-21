//objectcomments Hidden, non-modal w_filterextended, for the extended filter tests
forward
global type w_pfctest_filterextended from w_filterextended
end type
end forward

global type w_pfctest_filterextended from w_filterextended
boolean visible = false
windowtype windowtype = popup!
end type
global w_pfctest_filterextended w_pfctest_filterextended

forward prototypes
public function string of_getvaluessqlfortest (string as_dddw, string as_dbname)
end prototypes

public function string of_getvaluessqlfortest (string as_dddw, string as_dbname);Return of_GetValuesSQL(as_dddw, as_dbname)
end function

event open;// Overrides the dialog's setup, which needs the filter service's n_cst_filterattrib:
// the tests call the window's functions directly.  Closing then neither asks to save
// nor cancels (pfc_cancel calls CloseWithReturn).
ib_disableclosequery = true
inv_return.ii_rc = 0
end event

on w_pfctest_filterextended.create
call super::create
end on

on w_pfctest_filterextended.destroy
call super::destroy
end on
