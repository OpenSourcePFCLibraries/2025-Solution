//objectcomments OAuth 2.0 token service with a fake identity provider, for the OAuth 2.0 and SMTP client tests
forward
global type n_pfctest_oauth2 from n_cst_oauth2
end type
end forward

global type n_pfctest_oauth2 from n_cst_oauth2
end type
global n_pfctest_oauth2 n_pfctest_oauth2

type variables
Public:
// How the "browser" answers the authorization request: "fail" (it can't be opened),
// "none" (the user never signs in), "ok", "badstate" or "error"
string	is_browsermode = "fail"
// The authorization request the service opened
string	is_lasturl
// The identity provider's responses to of_Post, in order (the last one repeats), or
// no response at all
long		il_status[]
string	is_body[]
long		il_next
boolean	ib_unreachable
// What was posted, as <url>?<form>
string	is_posts[]
// The waits of the device code flow (they don't wait), in milliseconds
long		il_pauses[]
// Device code flow: the code shown to the user, and whether the user cancels
string	is_shownusercode
boolean	ib_declinedevice
end variables

forward prototypes
public subroutine of_addresponse (long al_status, string as_body)
public subroutine of_clear ()
public function string of_lastpost ()
public function string of_getparameter (string as_text, string as_name)
public function string of_endpointfortest (string as_which)
public function string of_codechallengefortest (string as_verifier)
public function string of_authorizationurlfortest (string as_redirecturi, string as_state, string as_challenge)
public subroutine of_setexpiresfortest (long al_seconds)
public function datetime of_addsecondsfortest (datetime adt_datetime, long al_seconds)
protected function integer of_post (string as_url, string as_body, ref long al_status, ref string as_response)
protected function boolean of_pause (long al_milliseconds)
end prototypes

public subroutine of_addresponse (long al_status, string as_body);il_status[UpperBound(il_status) + 1] = al_status
is_body[UpperBound(is_body) + 1] = as_body
end subroutine

public subroutine of_clear ();// Forgets the responses, what was posted, and the waits
long		ll_none[]
string	ls_none[]

il_status = ll_none
is_body = ls_none
is_posts = ls_none
il_pauses = ll_none
il_next = 0
ib_unreachable = False
end subroutine

public function string of_lastpost ();If UpperBound(is_posts) = 0 Then Return ""
Return is_posts[UpperBound(is_posts)]
end function

public function string of_getparameter (string as_text, string as_name);// The value of a parameter of a URL or a form, decoded (ASCII)
long		ll_start, ll_end, ll_idx
string	ls_value, ls_char, ls_result, ls_hex = "0123456789ABCDEF"

ll_start = Pos(as_text, "?" + as_name + "=")
If ll_start = 0 Then ll_start = Pos(as_text, "&" + as_name + "=")
If ll_start = 0 Then Return ""
ll_start += Len(as_name) + 2
ll_end = Pos(as_text, "&", ll_start)
If ll_end = 0 Then ll_end = Len(as_text) + 1
ls_value = Mid(as_text, ll_start, ll_end - ll_start)

ll_idx = 1
Do While ll_idx <= Len(ls_value)
	ls_char = Mid(ls_value, ll_idx, 1)
	If ls_char = "+" Then
		ls_result += " "
		ll_idx++
	ElseIf ls_char = "%" And ll_idx + 2 <= Len(ls_value) Then
		ls_result += String(Char((Pos(ls_hex, Upper(Mid(ls_value, ll_idx + 1, 1))) - 1) * 16 + &
			Pos(ls_hex, Upper(Mid(ls_value, ll_idx + 2, 1))) - 1))
		ll_idx += 3
	Else
		ls_result += ls_char
		ll_idx++
	End If
Loop

Return ls_result
end function

public function string of_endpointfortest (string as_which);Choose Case as_which
	Case "authorization"
		Return is_authorizationendpoint
	Case "token"
		Return is_tokenendpoint
	Case "device"
		Return is_deviceendpoint
	Case "parameters"
		Return is_parameters
End Choose
Return "?"
end function

public function string of_codechallengefortest (string as_verifier);Return of_CodeChallenge(as_verifier)
end function

public function string of_authorizationurlfortest (string as_redirecturi, string as_state, string as_challenge);Return of_AuthorizationURL(as_redirecturi, as_state, as_challenge)
end function

public subroutine of_setexpiresfortest (long al_seconds);// An access token that expires in al_seconds
is_accesstoken = "cached-token"
idt_expires = of_AddSeconds(DateTime(Today(), Now()), al_seconds)
end subroutine

public function datetime of_addsecondsfortest (datetime adt_datetime, long al_seconds);Return of_AddSeconds(adt_datetime, al_seconds)
end function

protected function integer of_post (string as_url, string as_body, ref long al_status, ref string as_response);// The fake identity provider
is_posts[UpperBound(is_posts) + 1] = as_url + "?" + as_body
If ib_unreachable Or UpperBound(il_status) = 0 Then Return -1

If il_next < UpperBound(il_status) Then il_next++
al_status = il_status[il_next]
as_response = is_body[il_next]
Return 1
end function

protected function boolean of_pause (long al_milliseconds);il_pauses[UpperBound(il_pauses) + 1] = al_milliseconds
Return Not ib_cancel
end function

event type long pfc_openbrowser(string as_url);// Plays the browser: sends the identity provider's redirect with curl.exe (which runs
// while the service waits)
string	ls_query, ls_curl

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
end event

event type long pfc_devicecode(string as_usercode, string as_verificationuri, string as_message);is_shownusercode = as_usercode
If ib_declinedevice Then Return 0
Return 1
end event

on n_pfctest_oauth2.create
call super::create
end on

on n_pfctest_oauth2.destroy
call super::destroy
end on
