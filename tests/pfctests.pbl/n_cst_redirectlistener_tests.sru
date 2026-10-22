//objectcomments Unit tests for the OAuth redirect listener (no identity provider needed)
forward
global type n_cst_redirectlistener_tests from testcase
end type
end forward

global type n_cst_redirectlistener_tests from testcase
event test_start ( )
event test_redirect ( )
event test_ignores_other_requests ( )
event test_error_redirect ( )
event test_timeout ( )
event test_not_started ( )
event test_real_http_client ( )
end type
global n_cst_redirectlistener_tests n_cst_redirectlistener_tests

type variables
Protected:
n_pfctest_redirectlistener	inv_listener
end variables

event setup;call super::setup;inv_listener = Create n_pfctest_redirectlistener
end event

event teardown;call super::teardown;If IsValid(inv_listener) Then Destroy inv_listener
end event

event test_start();// The listener chooses a free port on 127.0.0.1.
Long	ll_port

assertEquals("of_Start", 1, inv_listener.of_Start())
ll_port = inv_listener.of_GetPort()
assertTrue("port " + String(ll_port), ll_port > 0 And ll_port < 65536)
assertEquals("redirect URI", "http://127.0.0.1:" + String(ll_port) + "/callback", inv_listener.of_GetRedirectURI())
assertEquals("custom path", 1, inv_listener.of_Start("/auth"))
assertTrue("custom path URI", Right(inv_listener.of_GetRedirectURI(), 5) = "/auth")
assertEquals("invalid path", -1, inv_listener.of_Start("auth"))
inv_listener.of_Stop()
assertEquals("stopped", 0, inv_listener.of_GetPort())
assertEquals("stopped URI", "", inv_listener.of_GetRedirectURI())
end event

event test_redirect();// The redirect arrives before of_Wait is called (the connection is queued): its
// parameters are decoded and the browser gets the page.
LongPtr	ll_client
String	ls_response

If Not assertEquals("of_Start", 1, inv_listener.of_Start()) Then Return
ll_client = inv_listener.of_ClientConnect()
If Not assertTrue("connect", ll_client <> -1) Then Return
inv_listener.of_ClientSend(ll_client, "GET /callback?code=abc%2Bdef&state=x%20y+z&iss=http%3A%2F%2Flocalhost HTTP/1.1~r~nHost: 127.0.0.1~r~n~r~n")

assertEquals("of_Wait", 1, inv_listener.of_Wait(5))
assertEquals("code", "abc+def", inv_listener.of_GetParameter("code"))
assertEquals("state", "x y z", inv_listener.of_GetParameter("state"))
assertEquals("iss", "http://localhost", inv_listener.of_GetParameter("iss"))
assertEquals("missing", "", inv_listener.of_GetParameter("error"))
assertTrue("request line: " + inv_listener.of_GetRequest(), Left(inv_listener.of_GetRequest(), 14) = "GET /callback?")

ls_response = inv_listener.of_ClientReceive(ll_client)
assertTrue("200: " + Left(ls_response, 40), Left(ls_response, 15) = "HTTP/1.1 200 OK")
assertTrue("page", Pos(ls_response, "You can close this window") > 0)
inv_listener.of_ClientClose(ll_client)
end event

event test_ignores_other_requests();// A connection that sends nothing (as browsers open in advance), another path, and the
// callback path without a code are skipped; the wait goes on until the redirect.
LongPtr	ll_idle, ll_favicon, ll_nocode, ll_redirect
Long		ll_start

If Not assertEquals("of_Start", 1, inv_listener.of_Start()) Then Return
inv_listener.of_SetReadTimeout(500)

ll_idle = inv_listener.of_ClientConnect()
ll_favicon = inv_listener.of_ClientConnect()
inv_listener.of_ClientSend(ll_favicon, "GET /favicon.ico HTTP/1.1~r~nHost: 127.0.0.1~r~n~r~n")
ll_nocode = inv_listener.of_ClientConnect()
inv_listener.of_ClientSend(ll_nocode, "GET /callback?state=only HTTP/1.1~r~nHost: 127.0.0.1~r~n~r~n")
ll_redirect = inv_listener.of_ClientConnect()
inv_listener.of_ClientSend(ll_redirect, "GET /callback?code=C1&state=S1 HTTP/1.1~r~nHost: 127.0.0.1~r~n~r~n")

ll_start = CPU()
assertEquals("of_Wait", 1, inv_listener.of_Wait(10))
assertTrue("idle connection given up after the read timeout: " + String(CPU() - ll_start) + " ms", CPU() - ll_start < 3000)
assertEquals("code", "C1", inv_listener.of_GetParameter("code"))
assertTrue("favicon 404", Left(inv_listener.of_ClientReceive(ll_favicon), 22) = "HTTP/1.1 404 Not Found")
assertTrue("no code 404", Left(inv_listener.of_ClientReceive(ll_nocode), 22) = "HTTP/1.1 404 Not Found")
assertTrue("redirect 200", Left(inv_listener.of_ClientReceive(ll_redirect), 15) = "HTTP/1.1 200 OK")
inv_listener.of_ClientClose(ll_idle)
inv_listener.of_ClientClose(ll_favicon)
inv_listener.of_ClientClose(ll_nocode)
inv_listener.of_ClientClose(ll_redirect)
end event

event test_error_redirect();// The identity provider reports an error (the user refused): the wait ends too.
LongPtr	ll_client

If Not assertEquals("of_Start", 1, inv_listener.of_Start()) Then Return
ll_client = inv_listener.of_ClientConnect()
inv_listener.of_ClientSend(ll_client, "GET /callback?error=access_denied&error_description=The+user+said+no&state=S HTTP/1.1~r~n~r~n")
assertEquals("of_Wait", 1, inv_listener.of_Wait(5))
assertEquals("error", "access_denied", inv_listener.of_GetParameter("error"))
assertEquals("description", "The user said no", inv_listener.of_GetParameter("error_description"))
assertEquals("no code", "", inv_listener.of_GetParameter("code"))
inv_listener.of_ClientClose(ll_client)
end event

event test_timeout();// Without a redirect, of_Wait returns 0 after the time given.
Long	ll_start, ll_elapsed

If Not assertEquals("of_Start", 1, inv_listener.of_Start()) Then Return
ll_start = CPU()
assertEquals("of_Wait", 0, inv_listener.of_Wait(1))
ll_elapsed = CPU() - ll_start
assertTrue("about one second: " + String(ll_elapsed) + " ms", ll_elapsed >= 900 And ll_elapsed < 3000)
end event

event test_not_started();assertEquals("of_Wait before of_Start", -1, inv_listener.of_Wait(1))
end event

event test_real_http_client();// A real HTTP client (Windows' curl.exe, started while of_Wait runs) gets the page:
// of_Wait keeps processing while it waits, and the response is valid HTTP.
String	ls_curl, ls_out, ls_page
Integer	li_file
Long		ll_start

ls_curl = "C:\Windows\System32\curl.exe"
If Not FileExists(ls_curl) Then Return		// not on this version of Windows
If Not assertEquals("of_Start", 1, inv_listener.of_Start()) Then Return

ls_out = GetCurrentDirectory() + "\pfct_curl.txt"
FileDelete(ls_out)
Run(ls_curl + ' -s -o "' + ls_out + '" "' + inv_listener.of_GetRedirectURI() + '?code=real%20code&state=S9"', Minimized!)

assertEquals("of_Wait", 1, inv_listener.of_Wait(15))
assertEquals("code", "real code", inv_listener.of_GetParameter("code"))
assertEquals("state", "S9", inv_listener.of_GetParameter("state"))

// curl writes the page once it has the whole response
ll_start = CPU()
Do While Not FileExists(ls_out) And CPU() - ll_start < 5000
	Yield()
Loop
li_file = FileOpen(ls_out, TextMode!, Read!, Shared!)
If assertTrue("curl wrote the page", li_file > 0) Then
	FileReadEx(li_file, ls_page)
	FileClose(li_file)
	assertTrue("page: " + Left(ls_page, 60), Pos(ls_page, "You can close this window") > 0)
End If
FileDelete(ls_out)
end event

on n_cst_redirectlistener_tests.create
call super::create
end on

on n_cst_redirectlistener_tests.destroy
call super::destroy
end on
