//objectcomments Unit tests for the SQL behind the extended filter dialog's Values tab (#156; no database needed)
forward
global type n_cst_filterextended_tests from testcase
end type
end forward

global type n_cst_filterextended_tests from testcase
event test_column_without_dddw ( )
event test_column_with_dddw ( )
event test_dbname_without_table ( )
end type
global n_cst_filterextended_tests n_cst_filterextended_tests

type variables
Protected:
w_pfctest_filterextended	iw_filter
end variables

event setup;call super::setup;Open(iw_filter)
end event

event teardown;call super::teardown;If IsValid(iw_filter) Then Close(iw_filter)
end event

event test_column_without_dddw();// A column without a DropDownDataWindow lists its distinct values (Describe returns "?", "!" or "").
Constant String EXPECTED = "select distinct employee.emp_id from employee"

If Not assertTrue("window open", IsValid(iw_filter)) Then Return

assertEquals("no value (?)", EXPECTED, iw_filter.of_GetValuesSQLForTest("?", "employee.emp_id"))
assertEquals("not valid (!)", EXPECTED, iw_filter.of_GetValuesSQLForTest("!", "employee.emp_id"))
assertEquals("empty", EXPECTED, iw_filter.of_GetValuesSQLForTest("", "employee.emp_id"))
end event

event test_column_with_dddw();// A column with a DropDownDataWindow lists the values of the DDDW's SELECT.
String	ls_sql

If Not assertTrue("window open", IsValid(iw_filter)) Then Return

ls_sql = iw_filter.of_GetValuesSQLForTest("d_pfctest_head", "pfct_line.head_id")
assertTrue("the DDDW's SELECT: " + ls_sql, Pos(Upper(ls_sql), "FROM PFCT_HEAD") > 0)
assertTrue("not the column's: " + ls_sql, Pos(Lower(ls_sql), "select distinct") = 0)
end event

event test_dbname_without_table();// A dbname without a table name gives no SQL.
If Not assertTrue("window open", IsValid(iw_filter)) Then Return

assertEquals("no table", "", iw_filter.of_GetValuesSQLForTest("?", "emp_id"))
assertEquals("empty dbname", "", iw_filter.of_GetValuesSQLForTest("?", ""))
end event

on n_cst_filterextended_tests.create
call super::create
end on

on n_cst_filterextended_tests.destroy
call super::destroy
end on
