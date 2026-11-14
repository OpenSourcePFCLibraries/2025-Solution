//objectcomments Unit tests for the order in which the linkage service saves a master and its detail (update styles); pbunitmocks records the statements, nothing is sent to a database
forward
global type n_cst_dwsrv_linkage_update_tests from testcase
end type
end forward

global type n_cst_dwsrv_linkage_update_tests from testcase
event test_topdown_saves_master_first ( )
event test_bottomup_saves_detail_first ( )
event test_topdown_bottomup_inserts_down_deletes_up ( )
event test_bottomup_topdown_deletes_up_inserts_down ( )
event test_saving_resets_both_datawindows ( )
end type
global n_cst_dwsrv_linkage_update_tests n_cst_dwsrv_linkage_update_tests

type variables
Protected:
n_pbunit_mockdb	inv_db
n_tr					itr
w_pfctest_host		iw_host
u_pfctest_spydw	idw_head
u_pfctest_spydw	idw_line
end variables

forward prototypes
protected function string of_sequence ()
protected function integer of_save (integer ai_style)
end prototypes

event setup;call super::setup;// pfct_head (master) and pfct_line (detail), linked on head_id, both recording into one
// recorder. Head 1 and head 3 are as if retrieved, each with a line; then head 1 is changed,
// head 3 and its line are deleted, and head 2 is added with a line.
long	ll_row

inv_db = Create n_pbunit_mockdb
itr = Create n_tr
If Not assertEquals("connect: " + inv_db.of_GetError(), 1, inv_db.of_Connect(itr)) Then Return

Open(iw_host)
iw_host.OpenUserObject(idw_head)
iw_host.OpenUserObject(idw_line)
idw_head.DataObject = "d_pfctest_head"
idw_line.DataObject = "d_pfctest_line"
idw_head.SetTransObject(itr)
idw_line.SetTransObject(itr)

// One recorder for both, so the statements are in the order they were sent
Destroy idw_line.inv_recorder
idw_line.inv_recorder = idw_head.inv_recorder

If Not assertEquals("master linkage", 1, idw_head.of_SetLinkage(True)) Then Return
If Not assertEquals("detail linkage", 1, idw_line.of_SetLinkage(True)) Then Return
If Not assertEquals("of_SetMaster", 1, idw_line.inv_Linkage.of_SetMaster(idw_head)) Then Return
If Not assertEquals("of_Register", 1, idw_line.inv_Linkage.of_Register("head_id", "head_id")) Then Return

For ll_row = 1 To 2
	idw_head.InsertRow(0)
	idw_head.SetItem(ll_row, "head_id", ll_row * 2 - 1)		// 1, 3
	idw_head.SetItem(ll_row, "descr", "head " + String(ll_row * 2 - 1))
	idw_line.InsertRow(0)
	idw_line.SetItem(ll_row, "head_id", ll_row * 2 - 1)
	idw_line.SetItem(ll_row, "line_no", 1)
	idw_line.SetItem(ll_row, "qty", 10)
Next
idw_head.ResetUpdate()
idw_line.ResetUpdate()

idw_head.SetItem(1, "descr", "changed")
idw_head.DeleteRow(2)
idw_line.DeleteRow(2)
ll_row = idw_head.InsertRow(0)
idw_head.SetItem(ll_row, "head_id", 2)
idw_head.SetItem(ll_row, "descr", "head 2")
ll_row = idw_line.InsertRow(0)
idw_line.SetItem(ll_row, "head_id", 2)
idw_line.SetItem(ll_row, "line_no", 1)
idw_line.SetItem(ll_row, "qty", 5)
end event

event teardown;call super::teardown;If IsValid(iw_host) Then Close(iw_host)
If IsValid(inv_db) Then
	inv_db.of_Disconnect(itr)
	Destroy inv_db
End If
If IsValid(itr) Then Destroy itr
end event

protected function string of_sequence ();// The statements recorded, as "INSERT pfct_head 2, DELETE pfct_line 3, ...": the type, the
// table and the head_id it was for (the first number after "head_id").
string	ls_seq, ls_sql, ls_table, ls_id
long		ll_i, ll_pos

For ll_i = 1 To idw_head.inv_recorder.of_GetStatementCount()
	ls_sql = idw_head.inv_recorder.of_GetStatement(ll_i)
	If Pos(Lower(ls_sql), "pfct_line") > 0 Then ls_table = "pfct_line" Else ls_table = "pfct_head"
	// INSERT ... VALUES ( 2, ...: head_id is the first value; UPDATE/DELETE ... WHERE head_id = 3
	ll_pos = Pos(Lower(ls_sql), "where head_id = ")
	If ll_pos > 0 Then
		ls_id = Trim(Mid(ls_sql, ll_pos + 16, 3))
	Else
		ll_pos = Pos(Lower(ls_sql), "values ( ")
		ls_id = Trim(Mid(ls_sql, ll_pos + 9, 3))
	End If
	ls_id = Left(ls_id, Pos(ls_id + ",", ",") - 1)
	ls_id = Trim(Left(ls_id + " ", Pos(ls_id + " ", " ") - 1))
	If ll_i > 1 Then ls_seq += ", "
	ls_seq += idw_head.inv_recorder.of_GetStatementType(ll_i) + " " + ls_table + " " + ls_id
Next
Return ls_seq
end function

protected function integer of_save (integer ai_style);// Saves through the master's linkage service with an update style.
If Not assertEquals("update style", 1, idw_head.inv_Linkage.of_SetUpdateStyle(ai_style)) Then Return -1
Return idw_head.inv_Linkage.of_Update(False, True)
end function

event test_topdown_saves_master_first();// TOPDOWN saves the master, then the detail: the new head before its line, but also head 3
// before its line (a foreign key would refuse that delete).
assertEquals("save", 1, of_Save(idw_head.inv_Linkage.TOPDOWN))
assertEquals("sequence", "DELETE pfct_head 3, UPDATE pfct_head 1, INSERT pfct_head 2, DELETE pfct_line 3, INSERT pfct_line 2", of_Sequence())
assertEquals("db errors", 0, idw_head.inv_recorder.of_GetDbErrorCount())
end event

event test_bottomup_saves_detail_first();// BOTTOMUP saves the detail, then the master: head 3's line goes first, but the new line also
// goes before its head (a foreign key would refuse that insert).
assertEquals("save", 1, of_Save(idw_head.inv_Linkage.BOTTOMUP))
assertEquals("sequence", "DELETE pfct_line 3, INSERT pfct_line 2, DELETE pfct_head 3, UPDATE pfct_head 1, INSERT pfct_head 2", of_Sequence())
end event

event test_topdown_bottomup_inserts_down_deletes_up();// TOPDOWN_BOTTOMUP: inserts and updates master first, then deletes detail first. The order
// a foreign key needs: every parent exists before its children, and outlives them.
assertEquals("save", 1, of_Save(idw_head.inv_Linkage.TOPDOWN_BOTTOMUP))
assertEquals("sequence", "UPDATE pfct_head 1, INSERT pfct_head 2, INSERT pfct_line 2, DELETE pfct_line 3, DELETE pfct_head 3", of_Sequence())
assertEquals("db errors", 0, idw_head.inv_recorder.of_GetDbErrorCount())
end event

event test_bottomup_topdown_deletes_up_inserts_down();// BOTTOMUP_TOPDOWN: the same two passes, deletes (detail first) before inserts and updates
// (master first).
assertEquals("save", 1, of_Save(idw_head.inv_Linkage.BOTTOMUP_TOPDOWN))
assertEquals("sequence", "DELETE pfct_line 3, DELETE pfct_head 3, UPDATE pfct_head 1, INSERT pfct_head 2, INSERT pfct_line 2", of_Sequence())
end event

event test_saving_resets_both_datawindows();// After a successful save neither DataWindow has anything left to save.
assertEquals("save", 1, of_Save(idw_head.inv_Linkage.TOPDOWN_BOTTOMUP))
assertEquals("head modified", 0, idw_head.ModifiedCount())
assertEquals("head deleted", 0, idw_head.DeletedCount())
assertEquals("line modified", 0, idw_line.ModifiedCount())
assertEquals("line deleted", 0, idw_line.DeletedCount())
end event

on n_cst_dwsrv_linkage_update_tests.create
call super::create
end on

on n_cst_dwsrv_linkage_update_tests.destroy
call super::destroy
end on
