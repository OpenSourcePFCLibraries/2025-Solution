//objectcomments Hidden, non-modal w_openid_logon, for the OpenID Connect logon tests
forward
global type w_pfctest_openid_logon from w_openid_logon
end type
end forward

global type w_pfctest_openid_logon from w_openid_logon
boolean visible = false
windowtype windowtype = popup!
end type
global w_pfctest_openid_logon w_pfctest_openid_logon

forward prototypes
public function integer of_getgroupsfortest (string as_json, string as_claim, ref string as_groups[])
public function string of_decodeidtokenfortest (string as_idtoken)
public function integer of_loadidtokengroupsfortest (string as_idtoken, ref string as_groups[])
end prototypes

public function integer of_getgroupsfortest (string as_json, string as_claim, ref string as_groups[]);Return of_GetGroups(as_json, as_claim, as_groups)
end function

public function string of_decodeidtokenfortest (string as_idtoken);Return of_DecodeIDToken(as_idtoken)
end function

public function integer of_loadidtokengroupsfortest (string as_idtoken, ref string as_groups[]);// Uses the client ID and groups claim of the n_cst_openidattrib the window was opened with
String	ls_empty[]
Integer	li_rc

inv_openidattrib.is_groups = ls_empty
li_rc = of_LoadIDTokenGroups(as_idtoken)
as_groups = inv_openidattrib.is_groups
Return li_rc
end function

on w_pfctest_openid_logon.create
call super::create
end on

on w_pfctest_openid_logon.destroy
call super::destroy
end on
