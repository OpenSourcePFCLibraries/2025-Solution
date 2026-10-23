//objectcomments Unit tests for the OAuth 2.0 token service (a fake identity provider; no network needed)
forward
global type n_cst_oauth2_tests from testcase
end type
end forward

global type n_cst_oauth2_tests from testcase
event test_provider ( )
event test_settings ( )
event test_pkce ( )
event test_authorization_url ( )
event test_code_flow ( )
event test_code_flow_timeout ( )
event test_device_flow ( )
event test_device_flow_errors ( )
event test_client_credentials ( )
event test_refresh ( )
event test_authorize ( )
event test_expiry ( )
event test_token_errors ( )
event test_not_configured ( )
event test_real_http_client ( )
end type
global n_cst_oauth2_tests n_cst_oauth2_tests

type variables
Protected:
Constant String TOKENENDPOINT = "https://idp.example/token"
n_pfctest_oauth2	inv_oauth2
end variables

event setup;call super::setup;inv_oauth2 = Create n_pfctest_oauth2
end event

event teardown;call super::teardown;If IsValid(inv_oauth2) Then Destroy inv_oauth2
end event

event test_provider();// The endpoints of the well-known identity providers.
assertEquals("Microsoft", 1, inv_oauth2.of_SetProvider("Microsoft", "contoso.onmicrosoft.com"))
assertEquals("provider", "microsoft", inv_oauth2.of_GetProvider())
assertEquals("authorization", "https://login.microsoftonline.com/contoso.onmicrosoft.com/oauth2/v2.0/authorize", inv_oauth2.of_EndpointForTest("authorization"))
assertEquals("token", "https://login.microsoftonline.com/contoso.onmicrosoft.com/oauth2/v2.0/token", inv_oauth2.of_EndpointForTest("token"))
assertEquals("device", "https://login.microsoftonline.com/contoso.onmicrosoft.com/oauth2/v2.0/devicecode", inv_oauth2.of_EndpointForTest("device"))
assertEquals("Microsoft, no parameters", "", inv_oauth2.of_EndpointForTest("parameters"))

assertEquals("Microsoft, common", 1, inv_oauth2.of_SetProvider(inv_oauth2.MICROSOFT))
assertEquals("common tenant", "https://login.microsoftonline.com/common/oauth2/v2.0/token", inv_oauth2.of_EndpointForTest("token"))

assertEquals("Google", 1, inv_oauth2.of_SetProvider("google"))
assertEquals("Google provider", "google", inv_oauth2.of_GetProvider())
assertEquals("Google authorization", "https://accounts.google.com/o/oauth2/v2/auth", inv_oauth2.of_EndpointForTest("authorization"))
assertEquals("Google token", "https://oauth2.googleapis.com/token", inv_oauth2.of_EndpointForTest("token"))
assertEquals("Google device", "https://oauth2.googleapis.com/device/code", inv_oauth2.of_EndpointForTest("device"))
assertEquals("Google refresh token", "access_type=offline", inv_oauth2.of_EndpointForTest("parameters"))

// The application's own parameters are kept
inv_oauth2.of_SetParameters("&prompt=consent")
inv_oauth2.of_SetProvider("google")
assertEquals("parameters kept", "prompt=consent", inv_oauth2.of_EndpointForTest("parameters"))

assertEquals("unknown", -1, inv_oauth2.of_SetProvider("example"))
assertEquals("unknown keeps provider", "google", inv_oauth2.of_GetProvider())

inv_oauth2.of_SetEndpoints("https://idp.example/authorize", TOKENENDPOINT, "")
assertEquals("own endpoints", "", inv_oauth2.of_GetProvider())
assertEquals("own token endpoint", TOKENENDPOINT, inv_oauth2.of_EndpointForTest("token"))
end event

event test_settings();// Flows, the redirect path, and the client.
assertEquals("default flow", "code", inv_oauth2.of_GetFlow())
assertEquals("device", 1, inv_oauth2.of_SetFlow("DEVICE"))
assertEquals("device flow", inv_oauth2.DEVICECODE, inv_oauth2.of_GetFlow())
assertEquals("client credentials", 1, inv_oauth2.of_SetFlow(inv_oauth2.CLIENTCREDENTIALS))
assertEquals("unknown flow", -1, inv_oauth2.of_SetFlow("password"))
assertEquals("unknown keeps flow", "client_credentials", inv_oauth2.of_GetFlow())

assertEquals("redirect path", 1, inv_oauth2.of_SetRedirectPath("/oauth"))
assertEquals("invalid redirect path", -1, inv_oauth2.of_SetRedirectPath("oauth"))

inv_oauth2.of_SetClient(" client-123 ")
assertEquals("client ID trimmed", "client-123", inv_oauth2.of_GetClientID())
inv_oauth2.of_SetLoginHint("me@example.com")
assertEquals("login hint", "me@example.com", inv_oauth2.of_GetLoginHint())
inv_oauth2.of_SetScope("a b")
assertEquals("scope", "a b", inv_oauth2.of_GetScope())
end event

event test_pkce();// The S256 code challenge: the example in RFC 7636, appendix B.
assertEquals("RFC 7636 example", "E9Melhoa2OwvFrEMTJguCHaoeK1t8URWbuGJSstw-cM", &
	inv_oauth2.of_CodeChallengeForTest("dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk"))
end event

event test_authorization_url();// The authorization request has the client, the redirect URI, the scope, the state
// and the PKCE challenge, all encoded, and the login hint and other parameters.
string	ls_url

inv_oauth2.of_SetEndpoints("https://idp.example/authorize", TOKENENDPOINT, "")
inv_oauth2.of_SetClient("client-123")
inv_oauth2.of_SetScope("https://outlook.office.com/SMTP.Send offline_access")

ls_url = inv_oauth2.of_AuthorizationURLForTest("http://127.0.0.1:5000/callback", "S", "C")
assertTrue("endpoint: " + ls_url, Left(ls_url, 39) = "https://idp.example/authorize?response_")
assertEquals("response_type", "code", inv_oauth2.of_GetParameter(ls_url, "response_type"))
assertEquals("client_id", "client-123", inv_oauth2.of_GetParameter(ls_url, "client_id"))
assertEquals("redirect_uri", "http://127.0.0.1:5000/callback", inv_oauth2.of_GetParameter(ls_url, "redirect_uri"))
assertEquals("scope", "https://outlook.office.com/SMTP.Send offline_access", inv_oauth2.of_GetParameter(ls_url, "scope"))
assertTrue("scope encoded", Pos(ls_url, "SMTP.Send offline") = 0)
assertEquals("state", "S", inv_oauth2.of_GetParameter(ls_url, "state"))
assertEquals("code_challenge", "C", inv_oauth2.of_GetParameter(ls_url, "code_challenge"))
assertEquals("code_challenge_method", "S256", inv_oauth2.of_GetParameter(ls_url, "code_challenge_method"))
assertEquals("no login_hint", "", inv_oauth2.of_GetParameter(ls_url, "login_hint"))

inv_oauth2.of_SetEndpoints("https://idp.example/authorize?p=b2c_signin", TOKENENDPOINT, "")
inv_oauth2.of_SetLoginHint("me@example.com")
inv_oauth2.of_SetParameters("prompt=select_account")
ls_url = inv_oauth2.of_AuthorizationURLForTest("http://127.0.0.1:5000/callback", "S", "C")
assertTrue("query string kept: " + ls_url, Left(ls_url, 56) = "https://idp.example/authorize?p=b2c_signin&response_type")
assertEquals("login_hint", "me@example.com", inv_oauth2.of_GetParameter(ls_url, "login_hint"))
assertEquals("other parameters", "select_account", inv_oauth2.of_GetParameter(ls_url, "prompt"))
end event

event test_code_flow();// The authorization code flow, with curl.exe playing the browser: the redirect's state
// must match, the identity provider's error is reported, and the code is exchanged
// with the code verifier (and the client secret) for the tokens.
string	ls_post, ls_verifier

If Not FileExists("C:\Windows\System32\curl.exe") Then Return		// not on this version of Windows

inv_oauth2.of_SetEndpoints("https://idp.example/authorize", TOKENENDPOINT, "")
inv_oauth2.of_SetClient("client-123", "secret&1")
inv_oauth2.of_SetScope("mail")
inv_oauth2.of_SetTimeout(15)

inv_oauth2.is_browsermode = "fail"
assertEquals("browser can't be opened", -3, inv_oauth2.of_AuthorizationCode())

inv_oauth2.is_browsermode = "badstate"
assertEquals("state doesn't match", -5, inv_oauth2.of_AuthorizationCode())
assertEquals("redirect URI on the loopback interface", "http://127.0.0.1:", Left(inv_oauth2.of_GetParameter(inv_oauth2.is_lasturl, "redirect_uri"), 17))

inv_oauth2.is_browsermode = "error"
assertEquals("refused", -1, inv_oauth2.of_AuthorizationCode())
assertEquals("reason", "The user said no", inv_oauth2.of_GetError())
assertEquals("error code", "access_denied", inv_oauth2.of_GetErrorCode())
assertEquals("nothing posted", 0, UpperBound(inv_oauth2.is_posts))

inv_oauth2.is_browsermode = "ok"
inv_oauth2.of_AddResponse(200, '{"access_token":"at-1","token_type":"Bearer","expires_in":3599,"refresh_token":"rt-1","scope":"mail"}')
If Not assertEquals("signed in", 1, inv_oauth2.of_AuthorizationCode()) Then Return
assertEquals("access token", "at-1", inv_oauth2.of_GetAccessToken())
assertEquals("refresh token", "rt-1", inv_oauth2.of_GetRefreshToken())
assertEquals("no error", "", inv_oauth2.of_GetError())
assertFalse("not expired", inv_oauth2.of_IsExpired())

ls_post = inv_oauth2.of_LastPost()
assertTrue("token endpoint: " + ls_post, Left(ls_post, Len(TOKENENDPOINT) + 1) = TOKENENDPOINT + "?")
assertEquals("grant_type", "authorization_code", inv_oauth2.of_GetParameter(ls_post, "grant_type"))
assertEquals("code", "test-code", inv_oauth2.of_GetParameter(ls_post, "code"))
assertEquals("client_id", "client-123", inv_oauth2.of_GetParameter(ls_post, "client_id"))
assertEquals("client_secret", "secret&1", inv_oauth2.of_GetParameter(ls_post, "client_secret"))
assertEquals("same redirect URI", inv_oauth2.of_GetParameter(inv_oauth2.is_lasturl, "redirect_uri"), inv_oauth2.of_GetParameter(ls_post, "redirect_uri"))
ls_verifier = inv_oauth2.of_GetParameter(ls_post, "code_verifier")
assertEquals("verifier length", 43, Len(ls_verifier))
assertEquals("challenge of the verifier", inv_oauth2.of_CodeChallengeForTest(ls_verifier), inv_oauth2.of_GetParameter(inv_oauth2.is_lasturl, "code_challenge"))
end event

event test_code_flow_timeout();// The user doesn't sign in in time.
If Not FileExists("C:\Windows\System32\curl.exe") Then Return

inv_oauth2.of_SetEndpoints("https://idp.example/authorize", TOKENENDPOINT, "")
inv_oauth2.of_SetClient("client-123")
inv_oauth2.of_SetTimeout(1)
inv_oauth2.is_browsermode = "none"
assertEquals("timeout", -4, inv_oauth2.of_AuthorizationCode())
assertEquals("no token", "", inv_oauth2.of_GetAccessToken())
end event

event test_device_flow();// The device code flow: the code is shown, and the token endpoint is polled at the
// interval (5 seconds more after slow_down) until the user has signed in.
string	ls_post

inv_oauth2.of_SetEndpoints("", TOKENENDPOINT, "https://idp.example/devicecode")
inv_oauth2.of_SetClient("client-123")
inv_oauth2.of_SetScope("mail offline_access")
inv_oauth2.of_AddResponse(200, '{"device_code":"dc-1","user_code":"ABCD-EFGH","verification_uri":"https://idp.example/device","expires_in":900,"interval":2,"message":"Go"}')
inv_oauth2.of_AddResponse(400, '{"error":"authorization_pending"}')
inv_oauth2.of_AddResponse(400, '{"error":"slow_down"}')
inv_oauth2.of_AddResponse(400, '{"error":"authorization_pending"}')
inv_oauth2.of_AddResponse(200, '{"access_token":"at-d","expires_in":"3600"}')

If Not assertEquals("signed in", 1, inv_oauth2.of_DeviceCode()) Then Return
assertEquals("code shown", "ABCD-EFGH", inv_oauth2.is_shownusercode)
assertEquals("user code", "ABCD-EFGH", inv_oauth2.of_GetUserCode())
assertEquals("verification URI", "https://idp.example/device", inv_oauth2.of_GetVerificationURI())
assertEquals("access token", "at-d", inv_oauth2.of_GetAccessToken())
assertFalse("expiry from a string", IsNull(inv_oauth2.of_GetExpires()))

assertEquals("polls", 4, UpperBound(inv_oauth2.il_pauses))
assertEquals("interval", 2000, inv_oauth2.il_pauses[1])
assertEquals("still the interval", 2000, inv_oauth2.il_pauses[2])
assertEquals("slowed down", 7000, inv_oauth2.il_pauses[3])

ls_post = inv_oauth2.is_posts[1]
assertTrue("device endpoint: " + ls_post, Left(ls_post, 31) = "https://idp.example/devicecode?")
assertEquals("device client_id", "client-123", inv_oauth2.of_GetParameter(ls_post, "client_id"))
assertEquals("device scope", "mail offline_access", inv_oauth2.of_GetParameter(ls_post, "scope"))
ls_post = inv_oauth2.of_LastPost()
assertEquals("grant_type", "urn:ietf:params:oauth:grant-type:device_code", inv_oauth2.of_GetParameter(ls_post, "grant_type"))
assertEquals("device_code", "dc-1", inv_oauth2.of_GetParameter(ls_post, "device_code"))
assertEquals("no client_secret", 0, Pos(ls_post, "client_secret"))
end event

event test_device_flow_errors();// The device authorization is refused, the user declines or cancels, Google's
// verification_url, an incomplete response, and the code expiring.
inv_oauth2.of_SetEndpoints("", TOKENENDPOINT, "https://idp.example/devicecode")
inv_oauth2.of_SetClient("client-123")

inv_oauth2.of_AddResponse(400, '{"error":"invalid_client","error_description":"Unknown client"}')
assertEquals("device authorization refused", -1, inv_oauth2.of_DeviceCode())
assertEquals("its reason", "Unknown client", inv_oauth2.of_GetError())
assertEquals("its code", "invalid_client", inv_oauth2.of_GetErrorCode())

inv_oauth2.of_Clear()
inv_oauth2.of_AddResponse(200, '{"device_code":"dc","user_code":"U","verification_url":"https://www.google.com/device","expires_in":1800,"interval":5}')
inv_oauth2.of_AddResponse(428, '{"error":"access_denied"}')
assertEquals("user denied", -1, inv_oauth2.of_DeviceCode())
assertEquals("Google's verification_url", "https://www.google.com/device", inv_oauth2.of_GetVerificationURI())
assertEquals("denied code", "access_denied", inv_oauth2.of_GetErrorCode())

inv_oauth2.of_Clear()
inv_oauth2.ib_declinedevice = True
inv_oauth2.of_AddResponse(200, '{"device_code":"dc","user_code":"U","verification_uri":"https://idp.example/device"}')
assertEquals("user cancelled", 0, inv_oauth2.of_DeviceCode())
assertEquals("no poll", 1, UpperBound(inv_oauth2.is_posts))
inv_oauth2.ib_declinedevice = False

inv_oauth2.of_Clear()
inv_oauth2.of_AddResponse(200, '{"device_code":"dc","verification_uri":"https://idp.example/device"}')
assertEquals("no user code", -5, inv_oauth2.of_DeviceCode())

// The code expires after a second; the user never signs in
inv_oauth2.of_Clear()
inv_oauth2.of_AddResponse(200, '{"device_code":"dc","user_code":"U","verification_uri":"https://idp.example/device","expires_in":1,"interval":1}')
inv_oauth2.of_AddResponse(400, '{"error":"authorization_pending"}')
assertEquals("expired", -4, inv_oauth2.of_DeviceCode())
assertEquals("no pending error", "", inv_oauth2.of_GetError())
end event

event test_client_credentials();// The client credentials grant needs the secret, and sends the scope.
string	ls_post

inv_oauth2.of_SetEndpoints("", TOKENENDPOINT, "")
inv_oauth2.of_SetClient("client-123")
assertEquals("no secret", -6, inv_oauth2.of_ClientCredentials())
assertEquals("missing secret", "Missing: client secret", inv_oauth2.of_GetError())

inv_oauth2.of_SetClient("client-123", "s3cret")
inv_oauth2.of_SetScope("https://outlook.office365.com/.default")
inv_oauth2.of_AddResponse(200, '{"token_type":"Bearer","expires_in":3599,"access_token":"at-c"}')
If Not assertEquals("token", 1, inv_oauth2.of_ClientCredentials()) Then Return
assertEquals("access token", "at-c", inv_oauth2.of_GetAccessToken())
assertEquals("no refresh token", "", inv_oauth2.of_GetRefreshToken())
ls_post = inv_oauth2.of_LastPost()
assertEquals("grant_type", "client_credentials", inv_oauth2.of_GetParameter(ls_post, "grant_type"))
assertEquals("client_secret", "s3cret", inv_oauth2.of_GetParameter(ls_post, "client_secret"))
assertEquals("scope", "https://outlook.office365.com/.default", inv_oauth2.of_GetParameter(ls_post, "scope"))
end event

event test_refresh();// A refresh keeps the refresh token when the response has none; a refused one is
// cleared; Google gets no scope.
string	ls_post

inv_oauth2.of_SetProvider(inv_oauth2.MICROSOFT)
inv_oauth2.of_SetClient("client-123")
inv_oauth2.of_SetScope("mail offline_access")
assertEquals("no refresh token", -6, inv_oauth2.of_Refresh())

inv_oauth2.of_SetRefreshToken("rt-0")
inv_oauth2.of_AddResponse(200, '{"access_token":"at-r","expires_in":3600}')
If Not assertEquals("refreshed", 1, inv_oauth2.of_Refresh()) Then Return
assertEquals("access token", "at-r", inv_oauth2.of_GetAccessToken())
assertEquals("refresh token kept", "rt-0", inv_oauth2.of_GetRefreshToken())
ls_post = inv_oauth2.of_LastPost()
assertEquals("grant_type", "refresh_token", inv_oauth2.of_GetParameter(ls_post, "grant_type"))
assertEquals("refresh_token", "rt-0", inv_oauth2.of_GetParameter(ls_post, "refresh_token"))
assertEquals("scope", "mail offline_access", inv_oauth2.of_GetParameter(ls_post, "scope"))

inv_oauth2.of_Clear()
inv_oauth2.of_AddResponse(200, '{"access_token":"at-r2","refresh_token":"rt-1"}')
inv_oauth2.of_Refresh()
assertEquals("new refresh token", "rt-1", inv_oauth2.of_GetRefreshToken())

inv_oauth2.of_Clear()
inv_oauth2.of_AddResponse(400, '{"error":"invalid_grant","error_description":"The refresh token has expired"}')
assertEquals("refused", -1, inv_oauth2.of_Refresh())
assertEquals("refresh token cleared", "", inv_oauth2.of_GetRefreshToken())

inv_oauth2.of_Clear()
inv_oauth2.of_SetProvider(inv_oauth2.GOOGLE)
inv_oauth2.of_SetRefreshToken("rt-g")
inv_oauth2.of_AddResponse(200, '{"access_token":"at-g"}')
assertEquals("Google", 1, inv_oauth2.of_Refresh())
assertEquals("Google: no scope", 0, Pos(inv_oauth2.of_LastPost(), "scope="))
end event

event test_authorize();// of_Authorize uses the token it has, then the refresh token, and only then the flow.
inv_oauth2.of_SetEndpoints("", TOKENENDPOINT, "")
inv_oauth2.of_SetClient("client-123", "s")
inv_oauth2.of_SetFlow(inv_oauth2.CLIENTCREDENTIALS)

inv_oauth2.of_SetExpiresForTest(3600)
assertEquals("valid token", 1, inv_oauth2.of_Authorize())
assertEquals("nothing posted", 0, UpperBound(inv_oauth2.is_posts))

inv_oauth2.of_SetRefreshToken("rt-0")
inv_oauth2.of_AddResponse(200, '{"access_token":"at-r","expires_in":3600}')
assertEquals("refreshed", 1, inv_oauth2.of_Authorize())
assertEquals("one request", 1, UpperBound(inv_oauth2.is_posts))
assertEquals("refresh grant", "refresh_token", inv_oauth2.of_GetParameter(inv_oauth2.of_LastPost(), "grant_type"))

// The refresh token is refused: the flow gets a new token
inv_oauth2.of_Clear()
inv_oauth2.of_SetRefreshToken("rt-bad")
inv_oauth2.of_AddResponse(400, '{"error":"invalid_grant"}')
inv_oauth2.of_AddResponse(200, '{"access_token":"at-c"}')
assertEquals("flow after refused refresh", 1, inv_oauth2.of_Authorize())
assertEquals("two requests", 2, UpperBound(inv_oauth2.is_posts))
assertEquals("flow grant", "client_credentials", inv_oauth2.of_GetParameter(inv_oauth2.of_LastPost(), "grant_type"))
assertEquals("token from the flow", "at-c", inv_oauth2.of_GetAccessToken())
assertFalse("no expiry: not expired", inv_oauth2.of_IsExpired())

// The identity provider can't be reached: no sign-in either
inv_oauth2.of_Clear()
inv_oauth2.of_SetRefreshToken("rt-2")
inv_oauth2.ib_unreachable = True
assertEquals("unreachable", -2, inv_oauth2.of_Authorize())
assertEquals("only the refresh", 1, UpperBound(inv_oauth2.is_posts))
assertEquals("refresh token kept", "rt-2", inv_oauth2.of_GetRefreshToken())

inv_oauth2.of_Reset()
assertEquals("reset", "", inv_oauth2.of_GetRefreshToken())
assertTrue("reset: expired", inv_oauth2.of_IsExpired())
end event

event test_expiry();// A token that expires within a minute counts as expired; dates across midnight.
datetime	ldt_result

assertTrue("no token", inv_oauth2.of_IsExpired())
inv_oauth2.of_SetExpiresForTest(3600)
assertFalse("an hour", inv_oauth2.of_IsExpired())
inv_oauth2.of_SetExpiresForTest(30)
assertTrue("30 seconds", inv_oauth2.of_IsExpired())
inv_oauth2.of_SetExpiresForTest(-10)
assertTrue("in the past", inv_oauth2.of_IsExpired())

ldt_result = inv_oauth2.of_AddSecondsForTest(DateTime(Date(2026, 10, 23), Time(23, 59, 30)), 60)
assertEquals("after midnight", "2026-10-24 00:00:30", String(ldt_result, "yyyy-mm-dd hh:mm:ss"))
ldt_result = inv_oauth2.of_AddSecondsForTest(DateTime(Date(2026, 10, 24), Time(0, 0, 10)), -20)
assertEquals("before midnight", "2026-10-23 23:59:50", String(ldt_result, "yyyy-mm-dd hh:mm:ss"))
ldt_result = inv_oauth2.of_AddSecondsForTest(DateTime(Date(2026, 12, 31), Time(12, 0, 0)), 2 * 86400)
assertEquals("days", "2027-01-02 12:00:00", String(ldt_result, "yyyy-mm-dd hh:mm:ss"))
end event

event test_token_errors();// The token endpoint refuses, answers with something else, or can't be reached.
inv_oauth2.of_SetEndpoints("", TOKENENDPOINT, "")
inv_oauth2.of_SetClient("client-123", "s")

inv_oauth2.of_AddResponse(401, '{"error":"invalid_client","error_description":"Bad secret"}')
assertEquals("refused", -1, inv_oauth2.of_ClientCredentials())
assertEquals("description", "Bad secret", inv_oauth2.of_GetError())
assertEquals("code", "invalid_client", inv_oauth2.of_GetErrorCode())
assertEquals("response", '{"error":"invalid_client","error_description":"Bad secret"}', inv_oauth2.of_GetResponse())

inv_oauth2.of_Clear()
inv_oauth2.of_AddResponse(500, "<html>oops</html>")
assertEquals("not JSON", -1, inv_oauth2.of_ClientCredentials())
assertEquals("HTTP status", "HTTP 500", inv_oauth2.of_GetError())

inv_oauth2.of_Clear()
inv_oauth2.of_AddResponse(200, '{"token_type":"Bearer"}')
assertEquals("no access token", -5, inv_oauth2.of_ClientCredentials())

inv_oauth2.of_Clear()
inv_oauth2.of_AddResponse(200, '["at"]')
assertEquals("not an object", -5, inv_oauth2.of_ClientCredentials())

inv_oauth2.of_Clear()
inv_oauth2.ib_unreachable = True
assertEquals("unreachable", -2, inv_oauth2.of_ClientCredentials())
end event

event test_not_configured();// A flow without the settings it needs, or an unknown flow.
assertEquals("code: no client", -6, inv_oauth2.of_AuthorizationCode())
assertEquals("which", "Missing: client ID", inv_oauth2.of_GetError())
inv_oauth2.of_SetClient("client-123")
assertEquals("code: no endpoint", -6, inv_oauth2.of_AuthorizationCode())
assertEquals("which endpoint", "Missing: authorization endpoint", inv_oauth2.of_GetError())
assertEquals("device: no endpoint", -6, inv_oauth2.of_DeviceCode())
assertEquals("which device endpoint", "Missing: device authorization endpoint", inv_oauth2.of_GetError())
assertEquals("unknown flow", -6, inv_oauth2.of_Authorize("password"))
assertEquals("which flow", "Missing: flow", inv_oauth2.of_GetError())
assertEquals("nothing posted", 0, UpperBound(inv_oauth2.is_posts))
end event

event test_real_http_client();// The service's own of_Post (HTTPClient), with a token endpoint that can't be reached.
n_cst_oauth2	lnv_oauth2

lnv_oauth2 = Create n_cst_oauth2
lnv_oauth2.of_SetEndpoints("", "http://127.0.0.1:9/token", "")
lnv_oauth2.of_SetClient("client-123", "s")
assertEquals("unreachable", -2, lnv_oauth2.of_ClientCredentials())
assertEquals("no token", "", lnv_oauth2.of_GetAccessToken())
Destroy lnv_oauth2
end event

on n_cst_oauth2_tests.create
call super::create
end on

on n_cst_oauth2_tests.destroy
call super::destroy
end on
