//objectcomments Unit tests for the drop-down search service with drop-down list boxes (#52; no database needed)
forward
global type n_cst_dropdownsearch_tests from testcase
end type
end forward

global type n_cst_dropdownsearch_tests from testcase
event test_values_list_has_tabs ( )
event test_first_value ( )
event test_middle_value ( )
event test_last_value ( )
event test_value_not_in_list ( )
end type
global n_cst_dropdownsearch_tests n_cst_dropdownsearch_tests

type variables
Protected:
w_pfctest_host				iw_host
u_dw							idw
n_pfctest_dropdownsearch	inv_search
end variables

forward prototypes
protected function string of_focus (string as_status)
end prototypes

protected function string of_focus (string as_status);// Puts as_status in the status column (code table: Active A, Inactive I, Pending P),
// moves to it and fires the service's pfc_itemfocuschanged, as u_dw's itemfocuschanged
// does.  Returns the "previous text" the service stored: the value's display value.
dwobject	ldwo

idw.SetItem(1, "status", as_status)
idw.SetRow(1)
idw.SetColumn("status")
ldwo = idw.Object.status
inv_search.Event pfc_itemfocuschanged(1, ldwo)
Return inv_search.of_GetTextPrev()
end function

event setup;call super::setup;Open(iw_host)
iw_host.OpenUserObject(idw)
idw.DataObject = "d_pfctest_ddlb"
idw.InsertRow(0)
inv_search = Create n_pfctest_dropdownsearch
inv_search.of_SetRequestor(idw)
inv_search.of_Register("status")
end event

event teardown;call super::teardown;If IsValid(inv_search) Then Destroy inv_search
If IsValid(iw_host) Then Close(iw_host)
end event

event test_values_list_has_tabs();// The service counts the code table's entries by the tabs in Describe(".Values"):
// Describe must return real tab characters, not ~t.
n_cst_string	lnv_string

assertEquals("tabs", 3, lnv_string.of_CountOccurrences(idw.Describe("status.Values"), "~t", False))
end event

event test_first_value();assertEquals("Active", "Active", of_Focus("A"))
assertTrue("search on", inv_search.of_GetPerformSearch())
end event

event test_middle_value();assertEquals("Inactive", "Inactive", of_Focus("I"))
end event

event test_last_value();// The last entry is checked too (the loop ends after the number of entries).
assertEquals("Pending", "Pending", of_Focus("P"))
end event

event test_value_not_in_list();assertEquals("no match", "", of_Focus("X"))
assertTrue("search on", inv_search.of_GetPerformSearch())
end event

on n_cst_dropdownsearch_tests.create
call super::create
end on

on n_cst_dropdownsearch_tests.destroy
call super::destroy
end on
