//objectcomments Unit tests for values in DataWindow expressions (#40; no database needed)
forward
global type n_cst_expression_tests from testcase
end type
end forward

global type n_cst_expression_tests from testcase
event test_expressionstring ( )
event test_datastore_expression ( )
event test_datastore_comparison ( )
event test_datastore_optional_value ( )
event test_datawindow_expression ( )
end type
global n_cst_expression_tests n_cst_expression_tests

type variables
Protected:
// Code values with a single quote, a tilde and a double quote; "~~t" is a tilde and a t
Constant String CODE_QUOTE = "O'Brien"
Constant String CODE_TILDE = "a~~tb"
Constant String CODE_DOUBLE = 'say "hi"'

n_ds				ids
w_pfctest_host	iw_host
end variables

forward prototypes
protected subroutine of_fill (powerobject apo_data)
end prototypes

protected subroutine of_fill (powerobject apo_data);// Rows 1 to 4: plain, CODE_QUOTE, CODE_TILDE, CODE_DOUBLE
datawindow	ldw
datastore	lds
string		ls_codes[]
long			ll_row

ls_codes = {"plain", CODE_QUOTE, CODE_TILDE, CODE_DOUBLE}
For ll_row = 1 To UpperBound(ls_codes)
	If apo_data.TypeOf() = DataStore! Then
		lds = apo_data
		lds.InsertRow(0)
		lds.SetItem(ll_row, "id", ll_row)
		lds.SetItem(ll_row, "code", ls_codes[ll_row])
	Else
		ldw = apo_data
		ldw.InsertRow(0)
		ldw.SetItem(ll_row, "id", ll_row)
		ldw.SetItem(ll_row, "code", ls_codes[ll_row])
	End If
Next
end subroutine

event setup;call super::setup;ids = Create n_ds
ids.DataObject = "d_pfctest_linkage_master"
of_Fill(ids)
ids.of_SetBase(True)
end event

event teardown;call super::teardown;If IsValid(ids) Then Destroy ids
If IsValid(iw_host) Then Close(iw_host)
end event

event test_expressionstring();// A value as a string in an expression: quoted, with ~ and ' escaped.
n_cst_string	lnv_string
string			ls_null

SetNull(ls_null)
assertEquals("plain", "'abc'", lnv_string.of_ExpressionString("abc"))
assertEquals("empty", "''", lnv_string.of_ExpressionString(""))
assertEquals("single quote", "'O~~'Brien'", lnv_string.of_ExpressionString(CODE_QUOTE))
assertEquals("tilde", "'a~~~~tb'", lnv_string.of_ExpressionString(CODE_TILDE))
assertEquals("tilde before a quote", "'~~~~~~''", lnv_string.of_ExpressionString("~~'"))
assertEquals("double quote kept", "'say ~"hi~"'", lnv_string.of_ExpressionString(CODE_DOUBLE))
assertTrue("null", IsNull(lnv_string.of_ExpressionString(ls_null)))
end event

event test_datastore_expression();// of_BuildExpression from a row finds that row, whatever the value contains.
long	ll_row

For ll_row = 1 To ids.RowCount()
	assertEquals("row " + String(ll_row) + ": " + ids.inv_base.of_BuildExpression(ll_row, "code", "="), &
		ll_row, ids.Find(ids.inv_base.of_BuildExpression(ll_row, "code", "="), 1, ids.RowCount()))
Next
end event

event test_datastore_comparison();// of_BuildComparison gives the value part, for "code = " + ...
long	ll_row

For ll_row = 1 To ids.RowCount()
	assertEquals("row " + String(ll_row), ll_row, &
		ids.Find("code = " + ids.inv_base.of_BuildComparison(ll_row, "code"), 1, ids.RowCount()))
Next
end event

event test_datastore_optional_value();// A value passed in, such as text the user typed, is escaped too.
assertEquals("quote", 2, ids.Find(ids.inv_base.of_BuildExpression(0, "code", "=", CODE_QUOTE), 1, ids.RowCount()))
assertEquals("tilde", 3, ids.Find(ids.inv_base.of_BuildExpression(0, "code", "=", CODE_TILDE), 1, ids.RowCount()))
assertEquals("filter", 1, ids.SetFilter(ids.inv_base.of_BuildExpression(0, "code", "<>", CODE_QUOTE)))
ids.Filter()
assertEquals("filtered", 3, ids.RowCount())
end event

event test_datawindow_expression();// The same for the DataWindow services (n_cst_dwsrv).
u_dw				ldw
n_cst_dwsrv		lnv_dwsrv
long				ll_row

Open(iw_host)
iw_host.OpenUserObject(ldw)
ldw.DataObject = "d_pfctest_linkage_master"
of_Fill(ldw)
lnv_dwsrv = Create n_cst_dwsrv
lnv_dwsrv.of_SetRequestor(ldw)
For ll_row = 1 To ldw.RowCount()
	assertEquals("expression, row " + String(ll_row), ll_row, &
		ldw.Find(lnv_dwsrv.of_BuildExpression(ll_row, "code", "="), 1, ldw.RowCount()))
	assertEquals("comparison, row " + String(ll_row), ll_row, &
		ldw.Find("code = " + lnv_dwsrv.of_BuildComparison(ll_row, "code"), 1, ldw.RowCount()))
Next
Destroy lnv_dwsrv
end event

on n_cst_expression_tests.create
call super::create
end on

on n_cst_expression_tests.destroy
call super::destroy
end on
