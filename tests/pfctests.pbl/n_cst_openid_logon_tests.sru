//objectcomments Unit tests for the groups claim and ID token handling of w_openid_logon (no identity provider needed)
forward
global type n_cst_openid_logon_tests from testcase
end type
end forward

global type n_cst_openid_logon_tests from testcase
event test_groups_claim ( )
event test_decode_id_token ( )
event test_id_token_groups ( )
event test_id_token_audience ( )
event test_pkce ( )
event test_random_string ( )
event test_authorization_url ( )
event test_code_flow ( )
event test_code_flow_window ( )
end type
global n_cst_openid_logon_tests n_cst_openid_logon_tests

type variables
Protected:
// header.payload.signature; the payloads were made with base64url (no padding).
// {"aud":"client-123",...,"name":"Zoë Ångström ~~??>>","roles":["PEAT.Admin","PEAT.User"],"groups":["6f2b1c9e-..."]}
// (its payload contains "-" and "_", and needs padding)
Constant String TOKEN_ENTRA = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJjbGllbnQtMTIzIiwiaXNzIjoiaHR0cHM6Ly9sb2dpbi5leGFtcGxlL3YyLjAiLCJuYW1lIjoiWm_DqyDDhW5nc3Ryw7ZtIH5-Pz8-PiIsInJvbGVzIjpbIlBFQVQuQWRtaW4iLCJQRUFULlVzZXIiXSwiZ3JvdXBzIjpbIjZmMmIxYzllLTAwMDAtNDAwMC04MDAwLTAwMDAwMDAwMDAwMSJdfQ.c2lnbmF0dXJl"
// {"aud":["other-client","client-123"],"groups":"single-group","x":"?>"   }
Constant String TOKEN_AUDLIST = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOlsib3RoZXItY2xpZW50IiwiY2xpZW50LTEyMyJdLCJncm91cHMiOiJzaW5nbGUtZ3JvdXAiLCJ4IjoiPz4iICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIH0.c2lnbmF0dXJl"
// {"aud":"someone-else","groups":["g1"]   }
Constant String TOKEN_OTHERAPP = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJzb21lb25lLWVsc2UiLCJncm91cHMiOlsiZzEiXSAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICB9.c2lnbmF0dXJl"

w_pfctest_openid_logon	iw_logon
end variables

forward prototypes
protected function boolean of_open (string as_groupsclaim)
end prototypes

protected function boolean of_open (string as_groupsclaim);// Opens the logon window (hidden, not modal) for client "client-123".
n_cst_openidattrib	lnv_attrib

lnv_attrib.is_clientid = "client-123"
lnv_attrib.is_groupsclaim = as_groupsclaim
Return assertEquals("OpenWithParm", 1, OpenWithParm(iw_logon, lnv_attrib))
end function

event test_groups_claim();// A groups claim is an array of strings, or a single string.
String	ls_groups[]

If Not of_Open("groups") Then Return

assertEquals("array", 2, iw_logon.of_GetGroupsForTest('{"sub":"1","groups":["a","b"]}', "groups", ls_groups))
assertEquals("array 1", "a", ls_groups[1])
assertEquals("array 2", "b", ls_groups[2])
assertEquals("single string", 1, iw_logon.of_GetGroupsForTest('{"groups":"only"}', "groups", ls_groups))
assertEquals("single string value", "only", ls_groups[1])
assertEquals("other claim", 1, iw_logon.of_GetGroupsForTest('{"groups":["a"],"roles":["r"]}', "roles", ls_groups))
assertEquals("other claim value", "r", ls_groups[1])
assertEquals("non-strings skipped", 1, iw_logon.of_GetGroupsForTest('{"groups":[1,"x",null]}', "groups", ls_groups))
assertEquals("claim missing", 0, iw_logon.of_GetGroupsForTest('{"sub":"1"}', "groups", ls_groups))
assertEquals("missing leaves none", 0, UpperBound(ls_groups))
assertEquals("not JSON", -1, iw_logon.of_GetGroupsForTest("<html>error</html>", "groups", ls_groups))
end event

event test_decode_id_token();// The payload is base64url (with "-" and "_", no padding) and UTF-8.
String	ls_claims

If Not of_Open("groups") Then Return

ls_claims = iw_logon.of_DecodeIDTokenForTest(TOKEN_ENTRA)
assertTrue("JSON: " + ls_claims, Left(ls_claims, 1) = "{")
// ~~ is one ~ in PowerScript: the name is Zoë Ångström followed by two tildes, ??>>
assertTrue("UTF-8 name: " + ls_claims, Pos(ls_claims, "Zoë Ångström ~~~~??>>") > 0)
assertEquals("not a JWT", "", iw_logon.of_DecodeIDTokenForTest("not-a-token"))
assertEquals("empty payload", "", iw_logon.of_DecodeIDTokenForTest("a..b"))
assertEquals("payload not JSON", "", iw_logon.of_DecodeIDTokenForTest("a.bm90IGpzb24.b"))
end event

event test_id_token_groups();// The groups claim named by is_groupsclaim is read from the ID token.
String	ls_groups[]

If Not of_Open("roles") Then Return
assertEquals("roles", 2, iw_logon.of_LoadIDTokenGroupsForTest(TOKEN_ENTRA, ls_groups))
assertEquals("role 1", "PEAT.Admin", ls_groups[1])
assertEquals("role 2", "PEAT.User", ls_groups[2])
Close(iw_logon)

If Not of_Open("groups") Then Return
assertEquals("groups", 1, iw_logon.of_LoadIDTokenGroupsForTest(TOKEN_ENTRA, ls_groups))
assertEquals("group object ID", "6f2b1c9e-0000-4000-8000-000000000001", ls_groups[1])
assertEquals("no token", -1, iw_logon.of_LoadIDTokenGroupsForTest("", ls_groups))
assertEquals("no token, no groups", 0, UpperBound(ls_groups))
end event

event test_id_token_audience();// The ID token must have been issued to this client.
String	ls_groups[]

If Not of_Open("groups") Then Return
assertEquals("audience in a list", 1, iw_logon.of_LoadIDTokenGroupsForTest(TOKEN_AUDLIST, ls_groups))
assertEquals("single group", "single-group", ls_groups[1])
assertEquals("other application", -1, iw_logon.of_LoadIDTokenGroupsForTest(TOKEN_OTHERAPP, ls_groups))
assertEquals("other application, no groups", 0, UpperBound(ls_groups))
end event

event test_pkce();// The S256 code challenge (the example in RFC 7636, appendix B) and base64url.
Blob{2}	lblb_bytes

If Not of_Open("groups") Then Return
assertEquals("RFC 7636 example", "E9Melhoa2OwvFrEMTJguCHaoeK1t8URWbuGJSstw-cM", &
	iw_logon.of_CodeChallengeForTest("dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk"))
// FB FF is "+/8=" in base64
SetByte(lblb_bytes, 1, 251)
SetByte(lblb_bytes, 2, 255)
assertEquals("base64url", "-_8", iw_logon.of_Base64UrlForTest(lblb_bytes))
end event

event test_random_string();// 32 random bytes make a 43-character verifier of base64url characters, different each time.
String	ls_first, ls_second
Long		ll_idx
Boolean	lb_valid = True

If Not of_Open("groups") Then Return
ls_first = iw_logon.of_RandomStringForTest(32)
ls_second = iw_logon.of_RandomStringForTest(32)
assertEquals("length", 43, Len(ls_first))
assertTrue("different", ls_first <> ls_second)
For ll_idx = 1 To Len(ls_first)
	If Pos("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_", Mid(ls_first, ll_idx, 1)) = 0 Then lb_valid = False
Next
assertTrue("base64url characters: " + ls_first, lb_valid)
assertEquals("16 bytes", 22, Len(iw_logon.of_RandomStringForTest(16)))
assertEquals("no bytes", "", iw_logon.of_RandomStringForTest(0))
end event

event test_authorization_url();// The authorization request has the PKCE challenge, state and nonce, all encoded.
n_cst_openidattrib	lnv_attrib
String	ls_url

lnv_attrib.is_clientid = "client-123"
lnv_attrib.is_scope = "openid profile"
lnv_attrib.is_authorizationendpoint = "https://idp.example/authorize"
If Not assertEquals("OpenWithParm", 1, OpenWithParm(iw_logon, lnv_attrib)) Then Return

ls_url = iw_logon.of_AuthorizationURLForTest("http://127.0.0.1:5000/callback", "S", "N", "C")
assertTrue("endpoint: " + ls_url, Left(ls_url, 39) = "https://idp.example/authorize?response_")
assertEquals("response_type", "code", iw_logon.of_GetParameter(ls_url, "response_type"))
assertEquals("client_id", "client-123", iw_logon.of_GetParameter(ls_url, "client_id"))
assertEquals("redirect_uri", "http://127.0.0.1:5000/callback", iw_logon.of_GetParameter(ls_url, "redirect_uri"))
assertTrue("scope encoded", Pos(ls_url, "scope=openid ") = 0)
assertEquals("state", "S", iw_logon.of_GetParameter(ls_url, "state"))
assertEquals("nonce", "N", iw_logon.of_GetParameter(ls_url, "nonce"))
assertEquals("code_challenge", "C", iw_logon.of_GetParameter(ls_url, "code_challenge"))
assertEquals("code_challenge_method", "S256", iw_logon.of_GetParameter(ls_url, "code_challenge_method"))
assertEquals("no login_hint", "", iw_logon.of_GetParameter(ls_url, "login_hint"))
Close(iw_logon)

// An endpoint that already has a query string
lnv_attrib.is_authorizationendpoint = "https://idp.example/authorize?p=b2c_signin"
lnv_attrib.is_userid = "bruce"
If Not assertEquals("OpenWithParm 2", 1, OpenWithParm(iw_logon, lnv_attrib)) Then Return
ls_url = iw_logon.of_AuthorizationURLForTest("http://127.0.0.1:5000/callback", "S", "N", "C")
assertTrue("query string kept: " + ls_url, Left(ls_url, 56) = "https://idp.example/authorize?p=b2c_signin&response_type")
assertEquals("login_hint", "bruce", iw_logon.of_GetParameter(ls_url, "login_hint"))
end event

event test_code_flow();// The flow up to the token exchange, with curl.exe playing the browser: the redirect's
// state must match, the identity provider's error is reported, the wait times out, and
// a valid redirect goes on to the token endpoint (here, one that can't be reached).
n_cst_openidattrib	lnv_attrib
String	ls_error

If Not FileExists("C:\Windows\System32\curl.exe") Then Return		// not on this version of Windows

lnv_attrib.is_clientid = "client-123"
lnv_attrib.is_flow = "code"
lnv_attrib.is_authorizationendpoint = "https://idp.example/authorize"
lnv_attrib.is_tokenendpoint = "http://127.0.0.1:9/token"
lnv_attrib.il_timeout = 15
If Not assertEquals("OpenWithParm", 1, OpenWithParm(iw_logon, lnv_attrib)) Then Return

iw_logon.is_browsermode = "fail"
assertEquals("browser can't be opened", -3, iw_logon.of_Login_CodeForTest(ls_error))

iw_logon.is_browsermode = "badstate"
assertEquals("state doesn't match", -5, iw_logon.of_Login_CodeForTest(ls_error))
assertTrue("challenge sent: " + iw_logon.is_lasturl, Len(iw_logon.of_GetParameter(iw_logon.is_lasturl, "code_challenge")) = 43)

iw_logon.is_browsermode = "error"
assertEquals("refused", -1, iw_logon.of_Login_CodeForTest(ls_error))
assertEquals("reason", "The user said no", ls_error)

iw_logon.is_browsermode = "ok"
assertEquals("token endpoint unreachable", -2, iw_logon.of_Login_CodeForTest(ls_error))
assertTrue("OK enabled again", iw_logon.cb_ok.enabled)
Close(iw_logon)

lnv_attrib.il_timeout = 1
If Not assertEquals("OpenWithParm 2", 1, OpenWithParm(iw_logon, lnv_attrib)) Then Return
iw_logon.is_browsermode = "none"
assertEquals("timeout", -4, iw_logon.of_Login_CodeForTest(ls_error))
end event

event test_code_flow_window();// In the authorization code flow, the user ID and password aren't asked for.
n_cst_openidattrib	lnv_attrib

lnv_attrib.is_flow = "code"
If Not assertEquals("OpenWithParm", 1, OpenWithParm(iw_logon, lnv_attrib)) Then Return
assertFalse("no user ID", iw_logon.sle_userid.visible)
assertFalse("no password", iw_logon.sle_password.visible)
assertEquals("button", "&Sign In", iw_logon.cb_ok.text)
Close(iw_logon)

lnv_attrib.is_flow = "password"
If Not assertEquals("OpenWithParm 2", 1, OpenWithParm(iw_logon, lnv_attrib)) Then Return
assertTrue("user ID", iw_logon.sle_userid.visible)
assertTrue("password", iw_logon.sle_password.visible)
end event

event teardown;call super::teardown;If IsValid(iw_logon) Then Close(iw_logon)
end event

on n_cst_openid_logon_tests.create
call super::create
end on

on n_cst_openid_logon_tests.destroy
call super::destroy
end on
