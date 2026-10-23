//objectcomments Unit tests for the sort service with DataWindows that share data (#43; no database needed)
forward
global type n_cst_sort_tests from testcase
end type
end forward

global type n_cst_sort_tests from testcase
event test_powerbuilder_secondary_sort ( )
event test_primary ( )
event test_secondary ( )
event test_secondary_clear ( )
event test_secondary_keeps_primary ( )
end type
global n_cst_sort_tests n_cst_sort_tests

type variables
Protected:
w_pfctest_host	iw_host
u_dw				idw_primary
u_dw				idw_secondary
end variables

event setup;call super::setup;// Two DataWindows with the same DataObject; the second shares the first's data
long		ll_row
string	ls_codes[] = {"b", "c", "a"}

Open(iw_host)
iw_host.OpenUserObject(idw_primary)
iw_host.OpenUserObject(idw_secondary)
idw_primary.DataObject = "d_pfctest_linkage_master"
idw_secondary.DataObject = "d_pfctest_linkage_master"
For ll_row = 1 To 3
	idw_primary.InsertRow(0)
	idw_primary.SetItem(ll_row, "id", ll_row)
	idw_primary.SetItem(ll_row, "code", ls_codes[ll_row])
Next
idw_primary.ShareData(idw_secondary)
end event

event teardown;call super::teardown;If IsValid(iw_host) Then Close(iw_host)
end event

event test_powerbuilder_secondary_sort();// Why the service stores the criteria: PowerBuilder keeps a secondary's sort in the
// primary, and the secondary's Table.Sort is "?".  If this fails, PowerBuilder has
// changed, and of_SetTableSort may no longer be needed.
idw_secondary.SetSort("code D")
assertEquals("secondary", "?", idw_secondary.Describe("DataWindow.Table.Sort"))
assertEquals("primary", "code D", idw_primary.Describe("DataWindow.Table.Sort"))
end event

event test_primary();idw_primary.of_SetSort(True)
assertEquals("set", 1, idw_primary.inv_sort.of_SetSort("code D"))
assertEquals("get", "code D", idw_primary.inv_sort.of_GetSort())
idw_primary.Sort()
assertEquals("sorted", "c", idw_primary.GetItemString(1, "code"))
end event

event test_secondary();// The sort service on a secondary reads back the sort it set
idw_secondary.of_SetSort(True)
assertEquals("set", 1, idw_secondary.inv_sort.of_SetSort("code D"))
assertEquals("get", "code D", idw_secondary.inv_sort.of_GetSort())
idw_secondary.Sort()
assertEquals("sorted", "c", idw_secondary.GetItemString(1, "code"))
assertEquals("set again", 1, idw_secondary.inv_sort.of_SetSort("id A"))
assertEquals("get again", "id A", idw_secondary.inv_sort.of_GetSort())
end event

event test_secondary_clear();idw_secondary.of_SetSort(True)
idw_secondary.inv_sort.of_SetSort("code D")
assertEquals("clear", 1, idw_secondary.inv_sort.of_SetSort(""))
assertEquals("get", "", idw_secondary.inv_sort.of_GetSort())
end event

event test_secondary_keeps_primary();// Storing the criteria in the secondary doesn't change the primary's
idw_secondary.of_SetSort(True)
idw_secondary.inv_sort.of_SetSort("code D")
assertEquals("primary", "code D", idw_primary.Describe("DataWindow.Table.Sort"))
idw_primary.Sort()
assertEquals("sorted", "c", idw_primary.GetItemString(1, "code"))
end event

on n_cst_sort_tests.create
call super::create
end on

on n_cst_sort_tests.destroy
call super::destroy
end on
