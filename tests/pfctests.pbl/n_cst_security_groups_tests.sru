//objectcomments Unit tests for n_cst_security group membership (security database and external identity provider)
forward
global type n_cst_security_groups_tests from testcase
end type
end forward

global type n_cst_security_groups_tests from testcase
event test_db_membership_uses_groupings ( )
event test_external_ignores_groupings ( )
event test_external_user_not_in_security_users ( )
event test_external_normalizes_groups ( )
event test_external_default_group ( )
event test_external_unknown_app ( )
event test_external_permissions_follow_supplied_groups ( )
event test_external_group_priority ( )
event test_external_user_rows_override_groups ( )
event test_external_permissions_without_precache ( )
event test_window_with_ribbonbar ( )
event test_frame_bars_skipped ( )
event test_unknown_type_visible_only ( )
end type
global n_cst_security_groups_tests n_cst_security_groups_tests

type variables
// These tests need a PFC security database.  Set the environment variable PFC_SECURITY_INI
// to an INI file with the connection in a [Security] section (or the section named by
// PFC_SECURITY_SECTION).  When it is not set the tests fail.
// The fixture rows are inserted in a transaction that is rolled back after each test.
Protected:
Constant String APP = "pfct_secapp"
Constant String WIN = "w_pfct_sec"
Constant String TESTUSER = "pfct_user"

n_tr						itr_sec
n_pfctest_security	inv_security
Boolean					ib_ready
end variables

forward prototypes
protected function string of_getenv (string as_name)
protected function boolean of_exec (string as_sql)
protected function boolean of_createfixture ()
protected function string of_groupsummary ()
end prototypes

event setup;call super::setup;//////////////////////////////////////////////////////////////////////////////
String	ls_ini, ls_section

ls_ini = of_GetEnv("PFC_SECURITY_INI")
If ls_ini = "" Then
	fail("Not configured: set PFC_SECURITY_INI to an INI file with the security database connection")
	Return
End If

ls_section = of_GetEnv("PFC_SECURITY_SECTION")
If ls_section = "" Then ls_section = "Security"

itr_sec = Create n_tr
If Not assertEquals("of_Init(" + ls_ini + ", " + ls_section + ")", 1, itr_sec.of_Init(ls_ini, ls_section)) Then Return
itr_sec.AutoCommit = False

Connect Using itr_sec;
If Not assertEquals("Connect: " + itr_sec.SQLErrText, 0, itr_sec.SQLCode) Then Return

inv_security = Create n_pfctest_security
ib_ready = of_CreateFixture()
end event

event teardown;call super::teardown;If IsValid(inv_security) Then Destroy inv_security
If IsValid(itr_sec) Then
	If itr_sec.of_IsConnected() Then
		// discard the fixture rows
		Rollback Using itr_sec;
		Disconnect Using itr_sec;
	End If
	Destroy itr_sec
End If
end event

protected function string of_getenv (string as_name);// Returns the value of an environment variable, or "" if it is not set.
ContextKeyword	lcx_keyword
String			ls_values[]

If GetContextService("Keyword", lcx_keyword) <> 1 Then Return ""
If lcx_keyword.GetContextKeywords(as_name, ls_values) < 1 Then Return ""
If IsNull(ls_values[1]) Then Return ""
Return Trim(ls_values[1])
end function

protected function boolean of_exec (string as_sql);// Runs a SQL statement in the test transaction.
Execute Immediate :as_sql Using itr_sec;
Return assertEquals(as_sql + ": " + itr_sec.SQLErrText, 0, itr_sec.SQLCode)
end function

protected function boolean of_createfixture ();// Application, a user, three groups and settings for one window.
// pfct_user belongs to pfct_grp_a in security_groupings.
If Not of_Exec("insert into security_apps (application, description) values ('" + APP + "', 'PFC security tests')") Then Return False

If Not of_Exec("insert into security_users (name, description, priority, user_type) values ('" + TESTUSER + "', 'PFC test user', 0, 0)") Then Return False
If Not of_Exec("insert into security_users (name, description, priority, user_type) values ('pfct_grp_a', 'PFC test group A', 1, 1)") Then Return False
If Not of_Exec("insert into security_users (name, description, priority, user_type) values ('pfct_grp_b', 'PFC test group B', 2, 1)") Then Return False
If Not of_Exec("insert into security_users (name, description, priority, user_type) values ('pfct_grp_dflt', 'PFC test default group', 3, 1)") Then Return False

If Not of_Exec("insert into security_groupings (group_name, user_name) values ('pfct_grp_a', '" + TESTUSER + "')") Then Return False

// controls must be in the template before they can have settings
If Not of_Exec("insert into security_template (application, [window], control, description, object_type) values ('" + APP + "', '" + WIN + "', 'cb_a', 'Button A', 'CommandButton')") Then Return False
If Not of_Exec("insert into security_template (application, [window], control, description, object_type) values ('" + APP + "', '" + WIN + "', 'cb_b', 'Button B', 'CommandButton')") Then Return False
If Not of_Exec("insert into security_template (application, [window], control, description, object_type) values ('" + APP + "', '" + WIN + "', 'cb_ab', 'Button AB', 'CommandButton')") Then Return False
If Not of_Exec("insert into security_template (application, [window], control, description, object_type) values ('" + APP + "', '" + WIN + "', 'cb_user', 'Button User', 'CommandButton')") Then Return False

// cb_a: only group A has a setting
If Not of_Exec("insert into security_info (application, [window], control, user_name, status) values ('" + APP + "', '" + WIN + "', 'cb_a', 'pfct_grp_a', 'D')") Then Return False
// cb_b: only group B has a setting
If Not of_Exec("insert into security_info (application, [window], control, user_name, status) values ('" + APP + "', '" + WIN + "', 'cb_b', 'pfct_grp_b', 'I')") Then Return False
// cb_ab: both groups; group A has the higher precedence (lower priority number)
If Not of_Exec("insert into security_info (application, [window], control, user_name, status) values ('" + APP + "', '" + WIN + "', 'cb_ab', 'pfct_grp_a', 'E')") Then Return False
If Not of_Exec("insert into security_info (application, [window], control, user_name, status) values ('" + APP + "', '" + WIN + "', 'cb_ab', 'pfct_grp_b', 'D')") Then Return False
// cb_user: a user setting and a group setting
If Not of_Exec("insert into security_info (application, [window], control, user_name, status) values ('" + APP + "', '" + WIN + "', 'cb_user', '" + TESTUSER + "', 'I')") Then Return False
If Not of_Exec("insert into security_info (application, [window], control, user_name, status) values ('" + APP + "', '" + WIN + "', 'cb_user', 'pfct_grp_b', 'E')") Then Return False

Return True
end function

protected function string of_groupsummary ();// The groups in effect, comma separated, for comparisons and failure messages.
String	ls_groups[], ls_summary
Integer	li_idx, li_count

li_count = inv_security.of_GetGroups(ls_groups)
For li_idx = 1 To li_count
	If li_idx > 1 Then ls_summary += ","
	ls_summary += ls_groups[li_idx]
Next
Return ls_summary
end function

event test_db_membership_uses_groupings();// Without external groups, membership comes from security_groupings.
If Not ib_ready Then Return

assertEquals("of_InitSecurity", 1, inv_security.of_InitSecurity(itr_sec, APP, TESTUSER, ""))
assertEquals("groups", "pfct_grp_a", of_GroupSummary())
assertFalse("of_IsExternalGroups", inv_security.of_IsExternalGroups())
end event

event test_external_ignores_groupings();// External groups replace security_groupings rather than adding to it.
String	ls_groups[]

If Not ib_ready Then Return

ls_groups[1] = "pfct_grp_b"
assertEquals("of_InitSecurity", 1, inv_security.of_InitSecurity(itr_sec, APP, TESTUSER, ls_groups, ""))
assertEquals("groups", "pfct_grp_b", of_GroupSummary())
assertTrue("of_IsExternalGroups", inv_security.of_IsExternalGroups())
end event

event test_external_user_not_in_security_users();// With external groups the user does not need to be in security_users.
String	ls_groups[]

If Not ib_ready Then Return

assertEquals("database membership, unknown user", -3, inv_security.of_InitSecurity(itr_sec, APP, "pfct_sso", ""))

ls_groups[1] = "pfct_grp_b"
assertEquals("external membership, unknown user", 1, inv_security.of_InitSecurity(itr_sec, APP, "pfct_sso", ls_groups, ""))
assertEquals("groups", "pfct_grp_b", of_GroupSummary())
end event

event test_external_normalizes_groups();// Group names are trimmed and lower cased; blanks, nulls, duplicates and undefined groups are dropped.
String	ls_groups[]

If Not ib_ready Then Return

ls_groups[1] = "  PFCT_GRP_B "
ls_groups[2] = "pfct_no_such"
ls_groups[3] = "pfct_grp_b"
ls_groups[4] = ""
SetNull(ls_groups[5])
ls_groups[6] = "Pfct_Grp_A"

assertEquals("of_InitSecurity", 1, inv_security.of_InitSecurity(itr_sec, APP, TESTUSER, ls_groups, ""))
assertEquals("groups", "pfct_grp_b,pfct_grp_a", of_GroupSummary())
end event

event test_external_default_group();// When none of the supplied groups are defined the default group is used.
String	ls_groups[]

If Not ib_ready Then Return

ls_groups[1] = "pfct_no_such"

assertEquals("valid default", 1, inv_security.of_InitSecurity(itr_sec, APP, TESTUSER, ls_groups, "pfct_grp_dflt"))
assertEquals("groups", "pfct_grp_dflt", of_GroupSummary())

assertEquals("undefined default", -4, inv_security.of_InitSecurity(itr_sec, APP, TESTUSER, ls_groups, "pfct_no_such2"))
assertEquals("no default", -5, inv_security.of_InitSecurity(itr_sec, APP, TESTUSER, ls_groups, ""))
end event

event test_external_unknown_app();String	ls_groups[]

If Not ib_ready Then Return

ls_groups[1] = "pfct_grp_b"
assertEquals("of_InitSecurity", -2, inv_security.of_InitSecurity(itr_sec, "pfct_no_app", TESTUSER, ls_groups, ""))
end event

event test_external_permissions_follow_supplied_groups();// Settings come from the supplied groups only, not from the user's security_groupings rows.
String	ls_groups[]

If Not ib_ready Then Return

ls_groups[1] = "pfct_grp_b"
assertEquals("of_InitSecurity", 1, inv_security.of_InitSecurity(itr_sec, APP, TESTUSER, ls_groups, "", True))

assertEquals("cb_a (group A only)", inv_security.NOTSET, inv_security.of_GetPermissions(WIN, "cb_a"))
assertEquals("cb_b (group B only)", inv_security.INVISIBLE, inv_security.of_GetPermissions(WIN, "cb_b"))
assertEquals("cb_ab (both groups)", inv_security.DISABLE, inv_security.of_GetPermissions(WIN, "cb_ab"))
end event

event test_external_group_priority();// With several supplied groups the one with the lowest priority number wins.
String	ls_groups[]

If Not ib_ready Then Return

ls_groups[1] = "pfct_grp_b"
ls_groups[2] = "pfct_grp_a"
assertEquals("of_InitSecurity", 1, inv_security.of_InitSecurity(itr_sec, APP, TESTUSER, ls_groups, "", True))

assertEquals("cb_ab (group A wins)", inv_security.ENABLE, inv_security.of_GetPermissions(WIN, "cb_ab"))
assertEquals("cb_a", inv_security.DISABLE, inv_security.of_GetPermissions(WIN, "cb_a"))
assertEquals("cb_b", inv_security.INVISIBLE, inv_security.of_GetPermissions(WIN, "cb_b"))
end event

event test_external_user_rows_override_groups();// Settings for the user still apply and take precedence over the groups.
String	ls_groups[]

If Not ib_ready Then Return

ls_groups[1] = "pfct_grp_b"
assertEquals("of_InitSecurity", 1, inv_security.of_InitSecurity(itr_sec, APP, TESTUSER, ls_groups, "", True))

assertEquals("cb_user", inv_security.INVISIBLE, inv_security.of_GetPermissions(WIN, "cb_user"))
end event

event test_external_permissions_without_precache();// Same as test_external_permissions_follow_supplied_groups, loading settings per object.
String	ls_groups[]

If Not ib_ready Then Return

ls_groups[1] = "pfct_grp_b"
assertEquals("of_InitSecurity", 1, inv_security.of_InitSecurity(itr_sec, APP, TESTUSER, ls_groups, ""))
assertEquals("of_LoadSecurity", 1, inv_security.of_LoadSecurityForTest(WIN))

assertEquals("cb_a (group A only)", inv_security.NOTSET, inv_security.of_GetPermissions(WIN, "cb_a"))
assertEquals("cb_b (group B only)", inv_security.INVISIBLE, inv_security.of_GetPermissions(WIN, "cb_b"))
assertEquals("cb_ab (both groups)", inv_security.DISABLE, inv_security.of_GetPermissions(WIN, "cb_ab"))
assertEquals("cb_user", inv_security.INVISIBLE, inv_security.of_GetPermissions(WIN, "cb_user"))
end event

event test_window_with_ribbonbar();// A window with a ribbon bar (as pfc_w_frame has in PowerBuilder 2025) used to reach the
// "Unknown control" message and Halt Close in of_SetControlStatus.
w_pfctest_ribbon_host	lw_host
String					ls_groups[]
String					ls_win = "w_pfctest_ribbon_host"

If Not ib_ready Then Return

If Not of_Exec("insert into security_template (application, [window], control, description, object_type) values ('" + APP + "', '" + ls_win + "', 'cb_1', 'Button', 'CommandButton')") Then Return
If Not of_Exec("insert into security_info (application, [window], control, user_name, status) values ('" + APP + "', '" + ls_win + "', 'cb_1', 'pfct_grp_b', 'D')") Then Return

ls_groups[1] = "pfct_grp_b"
assertEquals("of_InitSecurity", 1, inv_security.of_InitSecurity(itr_sec, APP, TESTUSER, ls_groups, ""))

Open(lw_host)
assertTrue("of_SetSecurity", inv_security.of_SetSecurity(lw_host))
assertFalse("cb_1 disabled", lw_host.cb_1.Enabled)
Close(lw_host)
end event

event test_frame_bars_skipped();// The MDI tabbed bar is never secured, even with a row for it.
w_pfctest_host	lw_host
TabbedBar		ltb
String			ls_groups[]
String			ls_win = "w_pfctest_host"

If Not ib_ready Then Return

Open(lw_host)
lw_host.OpenUserObject(ltb)

If Not of_Exec("insert into security_template (application, [window], control, description, object_type) values ('" + APP + "', '" + ls_win + "', 'tabbedbar', 'Tabbed bar', 'TabbedBar')") Then Return
If Not of_Exec("insert into security_info (application, [window], control, user_name, status) values ('" + APP + "', '" + ls_win + "', 'tabbedbar', 'pfct_grp_b', 'I')") Then Return

ls_groups[1] = "pfct_grp_b"
assertEquals("of_InitSecurity", 1, inv_security.of_InitSecurity(itr_sec, APP, TESTUSER, ls_groups, ""))
assertTrue("of_SetSecurity", inv_security.of_SetSecurity(lw_host))
assertTrue("tabbed bar still visible", ltb.Visible)
Close(lw_host)
end event

event test_unknown_type_visible_only();// For a control type of_SetControlStatus does not list, only Visible can be set:
// 'D' and 'I' hide the control, 'E' shows it, and Enabled is left alone.
w_pfctest_host	lw_host
StaticText		lst
SingleLineEdit	lsle
CheckBox			lcbx
CommandButton	lcb
String			ls_groups[]
String			ls_win = "w_pfctest_host"

If Not ib_ready Then Return

If Not of_Exec("insert into security_template (application, [window], control, description, object_type) values ('" + APP + "', '" + ls_win + "', 'statictext', 'Text', 'StaticText')") Then Return
If Not of_Exec("insert into security_template (application, [window], control, description, object_type) values ('" + APP + "', '" + ls_win + "', 'singlelineedit', 'Edit', 'SingleLineEdit')") Then Return
If Not of_Exec("insert into security_template (application, [window], control, description, object_type) values ('" + APP + "', '" + ls_win + "', 'checkbox', 'Check', 'CheckBox')") Then Return
If Not of_Exec("insert into security_info (application, [window], control, user_name, status) values ('" + APP + "', '" + ls_win + "', 'statictext', 'pfct_grp_b', 'D')") Then Return
If Not of_Exec("insert into security_info (application, [window], control, user_name, status) values ('" + APP + "', '" + ls_win + "', 'singlelineedit', 'pfct_grp_b', 'I')") Then Return
If Not of_Exec("insert into security_info (application, [window], control, user_name, status) values ('" + APP + "', '" + ls_win + "', 'checkbox', 'pfct_grp_b', 'E')") Then Return

ls_groups[1] = "pfct_grp_b"
assertEquals("of_InitSecurity", 1, inv_security.of_InitSecurity(itr_sec, APP, TESTUSER, ls_groups, ""))
assertEquals("of_LoadSecurity", 1, inv_security.of_LoadSecurityForTest(ls_win))

Open(lw_host)
lw_host.OpenUserObject(lst)
lw_host.OpenUserObject(lsle)
lw_host.OpenUserObject(lcbx)
lw_host.OpenUserObject(lcb)
lcbx.Visible = False

assertEquals("D", 1, inv_security.of_SetControlStatusGenericForTest(lst, ls_win, "statictext"))
assertFalse("D hides", lst.Visible)
assertTrue("D leaves Enabled", lst.Enabled)
assertEquals("I", 1, inv_security.of_SetControlStatusGenericForTest(lsle, ls_win, "singlelineedit"))
assertFalse("I hides", lsle.Visible)
assertEquals("E", 1, inv_security.of_SetControlStatusGenericForTest(lcbx, ls_win, "checkbox"))
assertTrue("E shows", lcbx.Visible)
assertEquals("no row", 0, inv_security.of_SetControlStatusGenericForTest(lcb, ls_win, "commandbutton"))
assertTrue("no row leaves it", lcb.Visible)
Close(lw_host)
end event

on n_cst_security_groups_tests.create
call super::create
end on

on n_cst_security_groups_tests.destroy
call super::destroy
end on
