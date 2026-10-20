//objectcomments Unit tests for n_cst_dwsrv_linkage retrieve-style detail refresh (Issue #8)
forward
global type n_cst_dwsrv_linkage_tests from testcase
end type
end forward

global type n_cst_dwsrv_linkage_tests from testcase
event test_matching_keys_skips_retrieve ( )
event test_different_keys_retrieves ( )
event test_null_master_key_retrieves ( )
event test_null_detail_key_retrieves ( )
event test_both_keys_null_retrieves ( )
event test_null_key_of_other_datatype_retrieves ( )
end type
global n_cst_dwsrv_linkage_tests n_cst_dwsrv_linkage_tests

type variables
Protected:
w_pfctest_host			iw_host
u_dw						idw_master
u_pfctest_dw_probe	idw_detail
end variables

forward prototypes
protected function integer of_refreshdetail (long al_masterkey, long al_detailkey)
protected function integer of_refreshdetail (string as_mastercode, long al_detailkey)
protected function string of_retrievesummary (integer ai_rc)
end prototypes

event setup;call super::setup;//////////////////////////////////////////////////////////////////////////////
//
//	Master (id) -> detail (master_id) linked with the RETRIEVE style.
//	The detail is a u_pfctest_dw_probe, which counts and cancels retrieves.
//
//////////////////////////////////////////////////////////////////////////////
Open(iw_host)
iw_host.OpenUserObject(idw_master)
iw_host.OpenUserObject(idw_detail)

idw_master.DataObject = "d_pfctest_linkage_master"
idw_detail.DataObject = "d_pfctest_linkage_detail"
idw_detail.SetTransObject(SQLCA)

assertEquals("master of_SetLinkage", 1, idw_master.of_SetLinkage(True))
assertEquals("detail of_SetLinkage", 1, idw_detail.of_SetLinkage(True))
assertEquals("of_SetMaster", 1, idw_detail.inv_Linkage.of_SetMaster(idw_master))
assertEquals("of_Register", 1, idw_detail.inv_Linkage.of_Register("id", "master_id"))
assertEquals("of_SetStyle", 1, idw_detail.inv_Linkage.of_SetStyle(idw_detail.inv_Linkage.RETRIEVE))
end event

event teardown;call super::teardown;If IsValid(iw_host) Then Close(iw_host)
end event

event test_matching_keys_skips_retrieve();Integer	li_rc

li_rc = of_RefreshDetail(10, 10)

assertEquals("of_Refresh return code", 1, li_rc)
assertEquals("Retrieves when keys match (" + of_RetrieveSummary(li_rc) + ")", 0, idw_detail.il_retrievecount)
end event

event test_different_keys_retrieves();Integer	li_rc

li_rc = of_RefreshDetail(10, 20)

assertEquals("Retrieves when keys differ (" + of_RetrieveSummary(li_rc) + ")", 1, idw_detail.il_retrievecount)
end event

event test_null_master_key_retrieves();Long	ll_null
Integer	li_rc

SetNull(ll_null)
li_rc = of_RefreshDetail(ll_null, 10)

assertEquals("Retrieves when the master key is null (" + of_RetrieveSummary(li_rc) + ")", 1, idw_detail.il_retrievecount)
end event

event test_null_detail_key_retrieves();Long	ll_null
Integer	li_rc

SetNull(ll_null)
li_rc = of_RefreshDetail(10, ll_null)

assertEquals("Retrieves when the detail key is null (" + of_RetrieveSummary(li_rc) + ")", 1, idw_detail.il_retrievecount)
end event

event test_both_keys_null_retrieves();Long	ll_null
Integer	li_rc

SetNull(ll_null)
li_rc = of_RefreshDetail(ll_null, ll_null)

assertEquals("Retrieves when both keys are null (" + of_RetrieveSummary(li_rc) + ")", 1, idw_detail.il_retrievecount)
end event

protected function integer of_refreshdetail (long al_masterkey, long al_detailkey);//////////////////////////////////////////////////////////////////////////////
//
//	Function:		of_RefreshDetail
//
//	Description:	Loads one unmodified master row and one unmodified detail
//					row with the given keys, resets the retrieve counter, then
//					has the detail's linkage service refresh from master row 1
//					(which calls of_RetrieveDetails for the RETRIEVE style).
//
//////////////////////////////////////////////////////////////////////////////
idw_master.Reset()
idw_master.InsertRow(0)
idw_master.SetItem(1, "id", al_masterkey)
idw_master.ResetUpdate()

idw_detail.Reset()
idw_detail.InsertRow(0)
idw_detail.SetItem(1, "master_id", al_detailkey)
idw_detail.SetItem(1, "descr", "existing detail row")
idw_detail.ResetUpdate()

idw_detail.il_retrievecount = 0
idw_detail.il_dberrorcount = 0
idw_detail.is_lastdberror = ""

Return idw_detail.inv_Linkage.of_Refresh(1)
end function

event test_null_key_of_other_datatype_retrieves();// Issue #8: a null master key compared with a detail key of another datatype
// (string vs long).  The comparison must not be evaluated when a key is null.
String	ls_null
Integer	li_rc

// The retrieval argument must match the master's string key.
idw_detail.DataObject = "d_pfctest_linkage_detail_code"
idw_detail.SetTransObject(SQLCA)

assertEquals("of_Unregister", 1, idw_detail.inv_Linkage.of_Unregister())
assertEquals("of_Register", 1, idw_detail.inv_Linkage.of_Register("code", "master_id"))

SetNull(ls_null)
li_rc = of_RefreshDetail(ls_null, 10)

assertEquals("Retrieves when a null string master key is compared with a long detail key (" + of_RetrieveSummary(li_rc) + ")", &
	1, idw_detail.il_retrievecount)
end event

protected function integer of_refreshdetail (string as_mastercode, long al_detailkey);// Same as of_RefreshDetail(long, long), but sets the master's string "code" column.
idw_master.Reset()
idw_master.InsertRow(0)
idw_master.SetItem(1, "code", as_mastercode)
idw_master.ResetUpdate()

idw_detail.Reset()
idw_detail.InsertRow(0)
idw_detail.SetItem(1, "master_id", al_detailkey)
idw_detail.SetItem(1, "descr", "existing detail row")
idw_detail.ResetUpdate()

idw_detail.il_retrievecount = 0
idw_detail.il_dberrorcount = 0
idw_detail.is_lastdberror = ""

Return idw_detail.inv_Linkage.of_Refresh(1)
end function

protected function string of_retrievesummary (integer ai_rc);// Describes what happened during of_RefreshDetail, for failure messages.
String	ls_summary

ls_summary = "of_Refresh returned " + String(ai_rc)
If idw_detail.il_dberrorcount > 0 Then
	ls_summary += ", db errors = " + String(idw_detail.il_dberrorcount) + " (" + idw_detail.is_lastdberror + ")"
End If

Return ls_summary
end function

on n_cst_dwsrv_linkage_tests.create
call super::create
end on

on n_cst_dwsrv_linkage_tests.destroy
call super::destroy
end on
