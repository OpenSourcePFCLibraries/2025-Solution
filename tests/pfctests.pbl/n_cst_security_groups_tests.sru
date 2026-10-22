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
event test_check_functions_by_name ( )
event test_check_functions_by_control ( )
event test_apply_restrictions_never_enables ( )
event test_apply_restrictions_disable ( )
event test_apply_restrictions_invisible ( )
event test_apply_restrictions_menu ( )
event test_default_status_values ( )
event test_default_disable_without_settings ( )
event test_default_grant_overrides ( )
event test_default_invisible ( )
event test_default_menu_leaves ( )
event test_default_check_functions ( )
event test_map_groups_arrays ( )
event test_map_groups_ini ( )
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
protected function boolean of_addsetting (string as_window, string as_control, string as_user, string as_status, boolean ab_template)
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

protected function boolean of_addsetting (string as_window, string as_control, string as_user, string as_status, boolean ab_template);// Adds a setting (and, if ab_template, the template row it needs) to the fixture.
If ab_template Then
	If Not of_Exec("insert into security_template (application, [window], control, description, object_type) values ('" + APP + "', '" + as_window + "', '" + as_control + "', '" + as_control + "', 'Control')") Then Return False
End If
Return of_Exec("insert into security_info (application, [window], control, user_name, status) values ('" + APP + "', '" + as_window + "', '" + as_control + "', '" + as_user + "', '" + as_status + "')")
end function

event test_check_functions_by_name();// of_IsEnabledAllowed / of_IsVisibleAllowed for application code (fixture window, group B).
String	ls_groups[]

If Not ib_ready Then Return

ls_groups[1] = "pfct_grp_b"
assertEquals("of_InitSecurity", 1, inv_security.of_InitSecurity(itr_sec, APP, TESTUSER, ls_groups, ""))

assertFalse("cb_b (I) enabled", inv_security.of_IsEnabledAllowed(WIN, "cb_b"))
assertFalse("cb_b (I) visible", inv_security.of_IsVisibleAllowed(WIN, "cb_b"))
assertFalse("cb_ab (D) enabled", inv_security.of_IsEnabledAllowed(WIN, "cb_ab"))
assertTrue("cb_ab (D) visible", inv_security.of_IsVisibleAllowed(WIN, "cb_ab"))
assertFalse("cb_user (user I) enabled", inv_security.of_IsEnabledAllowed(WIN, "cb_user"))
assertTrue("cb_a (no row for B) enabled", inv_security.of_IsEnabledAllowed(WIN, "cb_a"))
assertTrue("cb_a (no row for B) visible", inv_security.of_IsVisibleAllowed(WIN, "cb_a"))
assertTrue("unknown window", inv_security.of_IsEnabledAllowed("w_pfct_none", "cb_x"))
assertFalse("names are not case sensitive", inv_security.of_IsVisibleAllowed(Upper(WIN), "CB_B"))
end event

event test_check_functions_by_control();// The window and control name are worked out from the control.
w_pfctest_ribbon_host	lw_host
String					ls_groups[]

If Not ib_ready Then Return
If Not of_AddSetting("w_pfctest_ribbon_host", "cb_1", "pfct_grp_b", "D", True) Then Return

ls_groups[1] = "pfct_grp_b"
assertEquals("of_InitSecurity", 1, inv_security.of_InitSecurity(itr_sec, APP, TESTUSER, ls_groups, ""))

Open(lw_host)
assertFalse("cb_1 (D) enabled", inv_security.of_IsEnabledAllowed(lw_host.cb_1))
assertTrue("cb_1 (D) visible", inv_security.of_IsVisibleAllowed(lw_host.cb_1))
Close(lw_host)
end event

event test_apply_restrictions_never_enables();// An E setting is ignored by of_ApplyRestrictions, so application state is kept;
// of_SetSecurity enables and shows the control.
w_pfctest_ribbon_host	lw_host
String					ls_groups[]

If Not ib_ready Then Return
If Not of_AddSetting("w_pfctest_ribbon_host", "cb_1", "pfct_grp_b", "E", True) Then Return

ls_groups[1] = "pfct_grp_b"
assertEquals("of_InitSecurity", 1, inv_security.of_InitSecurity(itr_sec, APP, TESTUSER, ls_groups, ""))

Open(lw_host)
lw_host.cb_1.Enabled = False
lw_host.cb_1.Visible = False
assertTrue("of_ApplyRestrictions", inv_security.of_ApplyRestrictions(lw_host))
assertFalse("still disabled", lw_host.cb_1.Enabled)
assertFalse("still hidden", lw_host.cb_1.Visible)

assertTrue("of_SetSecurity", inv_security.of_SetSecurity(lw_host))
assertTrue("of_SetSecurity enables", lw_host.cb_1.Enabled)
assertTrue("of_SetSecurity shows", lw_host.cb_1.Visible)
Close(lw_host)
end event

event test_apply_restrictions_disable();// D disables, but does not show a control the application hid.
w_pfctest_ribbon_host	lw_host
String					ls_groups[]

If Not ib_ready Then Return
If Not of_AddSetting("w_pfctest_ribbon_host", "cb_1", "pfct_grp_b", "D", True) Then Return

ls_groups[1] = "pfct_grp_b"
assertEquals("of_InitSecurity", 1, inv_security.of_InitSecurity(itr_sec, APP, TESTUSER, ls_groups, ""))

Open(lw_host)
lw_host.cb_1.Enabled = True
lw_host.cb_1.Visible = False
assertTrue("of_ApplyRestrictions", inv_security.of_ApplyRestrictions(lw_host))
assertFalse("disabled", lw_host.cb_1.Enabled)
assertFalse("still hidden", lw_host.cb_1.Visible)
Close(lw_host)
end event

event test_apply_restrictions_invisible();w_pfctest_ribbon_host	lw_host
String					ls_groups[]

If Not ib_ready Then Return
If Not of_AddSetting("w_pfctest_ribbon_host", "cb_1", "pfct_grp_b", "I", True) Then Return

ls_groups[1] = "pfct_grp_b"
assertEquals("of_InitSecurity", 1, inv_security.of_InitSecurity(itr_sec, APP, TESTUSER, ls_groups, ""))

Open(lw_host)
lw_host.cb_1.Enabled = True
lw_host.cb_1.Visible = True
assertTrue("of_ApplyRestrictions", inv_security.of_ApplyRestrictions(lw_host))
assertFalse("disabled", lw_host.cb_1.Enabled)
assertFalse("hidden", lw_host.cb_1.Visible)
Close(lw_host)
end event

event test_apply_restrictions_menu();// of_ApplyRestrictions(window, menu) restricts one menu without processing the window.
w_pfctest_host	lw_host
m_dw				lm_dw
String			ls_groups[]
String			ls_win = "w_pfctest_host"

If Not ib_ready Then Return
If Not of_AddSetting(ls_win, "m_insert", "pfct_grp_b", "D", True) Then Return
If Not of_AddSetting(ls_win, "m_addrow", "pfct_grp_b", "E", True) Then Return

ls_groups[1] = "pfct_grp_b"
assertEquals("of_InitSecurity", 1, inv_security.of_InitSecurity(itr_sec, APP, TESTUSER, ls_groups, ""))

Open(lw_host)
lm_dw = Create m_dw
lm_dw.m_table.m_insert.Enabled = True
lm_dw.m_table.m_addrow.Enabled = False
assertTrue("items set", inv_security.of_ApplyRestrictions(lw_host, lm_dw) > 0)
assertFalse("m_insert (D) disabled", lm_dw.m_table.m_insert.Enabled)
assertFalse("m_addrow (E) not enabled", lm_dw.m_table.m_addrow.Enabled)
Destroy lm_dw
Close(lw_host)
end event

event test_default_status_values();// The default status is off unless it is set; only D, I and NOTSET are accepted.
If Not ib_ready Then Return

assertEquals("off by default", "", inv_security.of_GetDefaultStatus())
assertEquals("E is not a default", -1, inv_security.of_SetDefaultStatus("E"))
assertEquals("invalid", -1, inv_security.of_SetDefaultStatus("X"))
assertEquals("lower case", 1, inv_security.of_SetDefaultStatus("d"))
assertEquals("D", "D", inv_security.of_GetDefaultStatus())
assertEquals("I", 1, inv_security.of_SetDefaultStatus("I"))
assertEquals("off", 1, inv_security.of_SetDefaultStatus(""))
assertEquals("off again", "", inv_security.of_GetDefaultStatus())
end event

event test_default_disable_without_settings();// Deny by default on a window with no settings: interactive controls are disabled
// (a hidden one stays hidden), labels are left as designed.
w_pfctest_host	lw_host
StaticText		lst
SingleLineEdit	lsle
CommandButton	lcb
CheckBox			lcbx
String			ls_groups[]

If Not ib_ready Then Return

ls_groups[1] = "pfct_grp_b"
assertEquals("of_InitSecurity", 1, inv_security.of_InitSecurity(itr_sec, APP, TESTUSER, ls_groups, ""))

Open(lw_host)
lw_host.OpenUserObject(lst)
lw_host.OpenUserObject(lsle)
lw_host.OpenUserObject(lcb)
lw_host.OpenUserObject(lcbx)
lcbx.Visible = False

assertFalse("no default: window without settings is left alone", inv_security.of_SetSecurity(lw_host))
assertTrue("no default: enabled", lcb.Enabled)

assertEquals("of_SetDefaultStatus", 1, inv_security.of_SetDefaultStatus(inv_security.DISABLE))
assertTrue("of_SetSecurity", inv_security.of_SetSecurity(lw_host))
assertFalse("singlelineedit disabled", lsle.Enabled)
assertTrue("singlelineedit visible", lsle.Visible)
assertFalse("commandbutton disabled", lcb.Enabled)
assertFalse("checkbox disabled", lcbx.Enabled)
assertFalse("hidden checkbox not shown", lcbx.Visible)
assertTrue("statictext left as designed", lst.Enabled)
assertTrue("statictext visible", lst.Visible)
Close(lw_host)
end event

event test_default_grant_overrides();// With deny by default, an E setting grants access; D still disables.
w_pfctest_ribbon_host	lw_host
SingleLineEdit			lsle
String					ls_groups[]

If Not ib_ready Then Return
If Not of_AddSetting("w_pfctest_ribbon_host", "cb_1", "pfct_grp_b", "E", True) Then Return

ls_groups[1] = "pfct_grp_b"
assertEquals("of_InitSecurity", 1, inv_security.of_InitSecurity(itr_sec, APP, TESTUSER, ls_groups, ""))
assertEquals("of_SetDefaultStatus", 1, inv_security.of_SetDefaultStatus(inv_security.DISABLE))

Open(lw_host)
lw_host.OpenUserObject(lsle)
lw_host.cb_1.Enabled = False
assertTrue("of_SetSecurity", inv_security.of_SetSecurity(lw_host))
assertTrue("cb_1 (E) enabled", lw_host.cb_1.Enabled)
assertFalse("singlelineedit (no setting) disabled", lsle.Enabled)

// The settled list is per call: a second call gives the same result
assertTrue("of_SetSecurity again", inv_security.of_SetSecurity(lw_host))
assertTrue("cb_1 still enabled", lw_host.cb_1.Enabled)
Close(lw_host)
end event

event test_default_invisible();// An INVISIBLE default hides controls without a setting.
w_pfctest_ribbon_host	lw_host
String					ls_groups[]

If Not ib_ready Then Return

ls_groups[1] = "pfct_grp_b"
assertEquals("of_InitSecurity", 1, inv_security.of_InitSecurity(itr_sec, APP, TESTUSER, ls_groups, ""))
assertEquals("of_SetDefaultStatus", 1, inv_security.of_SetDefaultStatus(inv_security.INVISIBLE))

Open(lw_host)
assertTrue("of_SetSecurity", inv_security.of_SetSecurity(lw_host))
assertFalse("cb_1 hidden", lw_host.cb_1.Visible)
assertFalse("cb_1 disabled", lw_host.cb_1.Enabled)
Close(lw_host)
end event

event test_default_menu_leaves();// The default applies to leaf menu items only: cascading menus stay available and
// separators are left alone.
w_pfctest_host	lw_host
m_dw				lm_dw
String			ls_groups[]
String			ls_win = "w_pfctest_host"

If Not ib_ready Then Return
If Not of_AddSetting(ls_win, "m_insert", "pfct_grp_b", "E", True) Then Return

ls_groups[1] = "pfct_grp_b"
assertEquals("of_InitSecurity", 1, inv_security.of_InitSecurity(itr_sec, APP, TESTUSER, ls_groups, ""))
assertEquals("of_SetDefaultStatus", 1, inv_security.of_SetDefaultStatus(inv_security.INVISIBLE))

Open(lw_host)
lm_dw = Create m_dw
lm_dw.m_table.m_insert.Enabled = True
lm_dw.m_table.m_insert.Visible = True
lm_dw.m_table.m_addrow.Enabled = True
lm_dw.m_table.m_addrow.Visible = True
assertTrue("items set", inv_security.of_ApplyRestrictions(lw_host, lm_dw) > 0)
assertTrue("m_table (cascading) enabled", lm_dw.m_table.Enabled)
assertTrue("m_table (cascading) visible", lm_dw.m_table.Visible)
assertTrue("m_insert (E) enabled", lm_dw.m_table.m_insert.Enabled)
assertTrue("m_insert (E) visible", lm_dw.m_table.m_insert.Visible)
assertFalse("m_addrow (no setting) disabled", lm_dw.m_table.m_addrow.Enabled)
assertFalse("m_addrow (no setting) hidden", lm_dw.m_table.m_addrow.Visible)
assertFalse("m_addrow toolbar button hidden", lm_dw.m_table.m_addrow.ToolbarItemVisible)
assertTrue("separator left alone", lm_dw.m_table.m_dash11.Visible)
Destroy lm_dw
Close(lw_host)
end event

event test_default_check_functions();// The check functions use the default for controls without a setting; by control, only
// for the controls the default applies to.
w_pfctest_ribbon_host	lw_host
StaticText				lst
String					ls_groups[]

If Not ib_ready Then Return
If Not of_AddSetting(WIN, "cb_e", "pfct_grp_b", "E", True) Then Return

ls_groups[1] = "pfct_grp_b"
assertEquals("of_InitSecurity", 1, inv_security.of_InitSecurity(itr_sec, APP, TESTUSER, ls_groups, ""))
assertEquals("of_SetDefaultStatus", 1, inv_security.of_SetDefaultStatus(inv_security.DISABLE))

assertFalse("cb_a (no row for B) not enabled", inv_security.of_IsEnabledAllowed(WIN, "cb_a"))
assertTrue("cb_a (no row for B) visible", inv_security.of_IsVisibleAllowed(WIN, "cb_a"))
assertFalse("unknown window not enabled", inv_security.of_IsEnabledAllowed("w_pfct_none", "cb_x"))
assertTrue("cb_e (E for B) enabled", inv_security.of_IsEnabledAllowed(WIN, "cb_e"))

Open(lw_host)
lw_host.OpenUserObject(lst)
assertFalse("cb_1 (no setting) not enabled", inv_security.of_IsEnabledAllowed(lw_host.cb_1))
assertTrue("statictext not affected", inv_security.of_IsEnabledAllowed(lst))
Close(lw_host)

assertEquals("of_SetDefaultStatus", 1, inv_security.of_SetDefaultStatus(inv_security.INVISIBLE))
assertFalse("cb_a not visible", inv_security.of_IsVisibleAllowed(WIN, "cb_a"))
end event

event test_map_groups_arrays();// Identity provider group names are mapped to security group names: case and spaces
// are ignored, unmapped names pass through, names mapped to "" are dropped.
String	ls_groups[], ls_from[], ls_to[], ls_mapped[], ls_null

If Not ib_ready Then Return
SetNull(ls_null)

ls_groups[1] = "App-Admins"
ls_groups[2] = "pfct_grp_b"
ls_groups[3] = "app-guests"
ls_groups[4] = ls_null
ls_from[1] = " app-admins "
ls_to[1] = "pfct_grp_a"
ls_from[2] = "APP-GUESTS"
ls_to[2] = ""

assertEquals("count", 2, inv_security.of_MapGroups(ls_groups, ls_from, ls_to, ls_mapped))
assertEquals("mapped", "pfct_grp_a", ls_mapped[1])
assertEquals("passed through", "pfct_grp_b", ls_mapped[2])

ls_to[3] = "extra"
assertEquals("from and to differ in size", -1, inv_security.of_MapGroups(ls_groups, ls_from, ls_to, ls_mapped))
assertEquals("nothing returned on error", 0, UpperBound(ls_mapped))
end event

event test_map_groups_ini();// The mapping read from an INI file, used with of_InitSecurity.
String	ls_ini, ls_groups[], ls_mapped[]
Integer	li_file

If Not ib_ready Then Return

ls_ini = GetCurrentDirectory() + "\pfct_groupmap.ini"
FileDelete(ls_ini)
assertEquals("no INI file", -1, inv_security.of_MapGroups(ls_groups, ls_ini, "GroupMap", ls_mapped))

li_file = FileOpen(ls_ini, LineMode!, Write!, LockWrite!, Replace!)
If Not assertTrue("create " + ls_ini, li_file > 0) Then Return
FileWrite(li_file, "[GroupMap]")
FileWrite(li_file, "idp-group-a=pfct_grp_a")
FileWrite(li_file, "idp-ignored=")
FileClose(li_file)

ls_groups[1] = "IDP-Group-A"
ls_groups[2] = "idp-ignored"
ls_groups[3] = "pfct_grp_b"
assertEquals("count", 2, inv_security.of_MapGroups(ls_groups, ls_ini, "GroupMap", ls_mapped))
assertEquals("mapped", "pfct_grp_a", ls_mapped[1])
assertEquals("passed through", "pfct_grp_b", ls_mapped[2])

assertEquals("of_InitSecurity", 1, inv_security.of_InitSecurity(itr_sec, APP, TESTUSER, ls_mapped, ""))
assertEquals("groups", "pfct_grp_a,pfct_grp_b", of_GroupSummary())
FileDelete(ls_ini)
end event

on n_cst_security_groups_tests.create
call super::create
end on

on n_cst_security_groups_tests.destroy
call super::destroy
end on
