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

type variables
Public:
// How the "browser" answers the authorization request: "fail" (it can't be opened),
// "none" (the user never signs in), "ok", "badstate" or "error"
string	is_browsermode = "fail"
// The authorization request the window opened
string	is_lasturl
end variables

forward prototypes
public function integer of_getgroupsfortest (string as_json, string as_claim, ref string as_groups[])
public function string of_decodeidtokenfortest (string as_idtoken)
public function integer of_loadidtokengroupsfortest (string as_idtoken, ref string as_groups[])
public function string of_randomstringfortest (integer ai_bytes)
public function string of_base64urlfortest (blob ablb_data)
public function string of_codechallengefortest (string as_verifier)
public function string of_authorizationurlfortest (string as_redirecturi, string as_state, string as_nonce, string as_challenge)
public function integer of_login_codefortest (ref string as_error)
public function string of_getparameter (string as_url, string as_name)
protected function integer of_openbrowser (string as_url)
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

public function string of_randomstringfortest (integer ai_bytes);Return of_RandomString(ai_bytes)
end function

public function string of_base64urlfortest (blob ablb_data);Return of_Base64Url(ablb_data)
end function

public function string of_codechallengefortest (string as_verifier);Return of_CodeChallenge(as_verifier)
end function

public function string of_authorizationurlfortest (string as_redirecturi, string as_state, string as_nonce, string as_challenge);Return of_AuthorizationURL(as_redirecturi, as_state, as_nonce, as_challenge)
end function

public function integer of_login_codefortest (ref string as_error);Integer	li_rc

li_rc = of_Login_Code()
as_error = is_error
If IsValid(inv_listener) Then inv_listener.of_Stop()
Return li_rc
end function

public function string of_getparameter (string as_url, string as_name);// The value of a query parameter, URL-decoded (enough for the redirect URI)
Long		ll_start, ll_end
String	ls_value

ll_start = Pos(as_url, "?" + as_name + "=")
If ll_start = 0 Then ll_start = Pos(as_url, "&" + as_name + "=")
If ll_start = 0 Then Return ""
ll_start += Len(as_name) + 2
ll_end = Pos(as_url, "&", ll_start)
If ll_end = 0 Then ll_end = Len(as_url) + 1
ls_value = Mid(as_url, ll_start, ll_end - ll_start)
Do While Pos(Upper(ls_value), "%3A") > 0
	ls_value = Replace(ls_value, Pos(Upper(ls_value), "%3A"), 3, ":")
Loop
Do While Pos(Upper(ls_value), "%2F") > 0
	ls_value = Replace(ls_value, Pos(Upper(ls_value), "%2F"), 3, "/")
Loop
Return ls_value
end function

protected function integer of_openbrowser (string as_url);// Plays the browser: sends the identity provider's redirect with curl.exe (which runs
// while the window waits)
String	ls_query, ls_curl

is_lasturl = as_url
ls_curl = "C:\Windows\System32\curl.exe"
Choose Case is_browsermode
	Case "none"
		Return 1
	Case "ok"
		ls_query = "code=test-code&state=" + of_GetParameter(as_url, "state")
	Case "badstate"
		ls_query = "code=test-code&state=not-the-state"
	Case "error"
		ls_query = "error=access_denied&error_description=The+user+said+no&state=" + of_GetParameter(as_url, "state")
	Case Else
		Return -1
End Choose

If Not FileExists(ls_curl) Then Return -1
Run(ls_curl + ' -s -o NUL "' + of_GetParameter(as_url, "redirect_uri") + "?" + ls_query + '"', Minimized!)
Return 1
end function

on w_pfctest_openid_logon.create
call super::create
end on

on w_pfctest_openid_logon.destroy
call super::destroy
end on
