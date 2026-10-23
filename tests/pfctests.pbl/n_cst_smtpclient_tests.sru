//objectcomments Unit tests for the SMTPClient class and its OAuth 2.0 token service (nothing is sent)
forward
global type n_cst_smtpclient_tests from testcase
end type
end forward

global type n_cst_smtpclient_tests from testcase
event test_setoauth2 ( )
event test_provider_defaults ( )
event test_authorize ( )
event test_default_scope ( )
event test_setaccesstoken ( )
event test_send_authorization_failed ( )
end type
global n_cst_smtpclient_tests n_cst_smtpclient_tests

type variables
Protected:
n_smtpclient		inv_smtp
// The token service of inv_smtp, with a fake identity provider (of_UseFake)
n_pfctest_oauth2	inv_fake
end variables

forward prototypes
protected subroutine of_usefake ()
end prototypes

protected subroutine of_usefake ();// Gives inv_smtp a token service with a fake identity provider (inv_smtp destroys it)
inv_smtp.of_SetOAuth2(False)
inv_fake = Create n_pfctest_oauth2
inv_smtp.inv_oauth2 = inv_fake
end subroutine

event setup;call super::setup;inv_smtp = Create n_smtpclient
end event

event teardown;call super::teardown;If IsValid(inv_smtp) Then Destroy inv_smtp
end event

event test_setoauth2();// The token service starts and stops.
assertEquals("start", 1, inv_smtp.of_SetOAuth2(True))
assertTrue("started", IsValid(inv_smtp.inv_oauth2))
assertEquals("already started", 0, inv_smtp.of_SetOAuth2(True))
assertEquals("stop", 1, inv_smtp.of_SetOAuth2(False))
assertFalse("stopped", IsValid(inv_smtp.inv_oauth2))
assertEquals("already stopped", 0, inv_smtp.of_SetOAuth2(False))
assertEquals("no service", -6, inv_smtp.of_Authorize())
end event

event test_provider_defaults();// A well-known provider sets its SMTP server, unless the application has set one.
assertEquals("Microsoft", 1, inv_smtp.of_SetOAuth2("microsoft", "contoso.com", "client-123", ""))
assertEquals("provider", "microsoft", inv_smtp.inv_oauth2.of_GetProvider())
assertEquals("client", "client-123", inv_smtp.inv_oauth2.of_GetClientID())
assertEquals("host", "smtp.office365.com", inv_smtp.Host)
assertEquals("port", 587, inv_smtp.Port)
assertTrue("STARTTLS", inv_smtp.EnableTLS)
assertEquals("authorization code flow", "code", inv_smtp.inv_oauth2.of_GetFlow())
Destroy inv_smtp

inv_smtp = Create n_smtpclient
inv_smtp.Host = "mail.example.com"
inv_smtp.Port = 25
assertEquals("Google", 1, inv_smtp.of_SetOAuth2("google", "client-g", "secret-g"))
assertEquals("own host", "mail.example.com", inv_smtp.Host)
assertEquals("own port", 25, inv_smtp.Port)
Destroy inv_smtp

inv_smtp = Create n_smtpclient
assertEquals("Google defaults", 1, inv_smtp.of_SetOAuth2("google", "client-g", "secret-g"))
assertEquals("Gmail host", "smtp.gmail.com", inv_smtp.Host)
assertEquals("unknown", -1, inv_smtp.of_SetOAuth2("example", "c", ""))
end event

event test_authorize();// The token goes to XOAUTH2; UserName is the login hint (and the other way round).
of_UseFake()
inv_fake.of_SetProvider(inv_fake.MICROSOFT)
inv_fake.of_SetClient("client-123", "s")
inv_smtp.UserName = "me@contoso.com"
inv_fake.of_AddResponse(200, '{"access_token":"at-smtp","expires_in":3600}')

If Not assertEquals("authorized", 1, inv_smtp.of_Authorize(inv_fake.CLIENTCREDENTIALS)) Then Return
assertEquals("XOAUTH2", inv_smtp.AUTH_XOAUTH2, inv_smtp.AuthType)
assertEquals("token", "at-smtp", inv_smtp.XOAuth2AccessToken)
assertEquals("login hint", "me@contoso.com", inv_fake.of_GetLoginHint())

// No UserName: the login hint is the mailbox
Destroy inv_smtp
inv_smtp = Create n_smtpclient
of_UseFake()
inv_fake.of_SetProvider(inv_fake.MICROSOFT)
inv_fake.of_SetClient("client-123", "s")
inv_fake.of_SetLoginHint("other@contoso.com")
inv_fake.of_AddResponse(200, '{"access_token":"at-2"}')
assertEquals("authorized 2", 1, inv_smtp.of_Authorize(inv_fake.CLIENTCREDENTIALS))
assertEquals("user name", "other@contoso.com", inv_smtp.UserName)

// Refused
inv_fake.of_Reset()
inv_fake.of_Clear()
inv_fake.of_AddResponse(401, '{"error":"invalid_client"}')
assertEquals("refused", -1, inv_smtp.of_Authorize(inv_fake.CLIENTCREDENTIALS))
assertEquals("reason", "invalid_client", inv_smtp.inv_oauth2.of_GetError())
end event

event test_default_scope();// The SMTP scope of the provider and flow, unless the application set a scope.
of_UseFake()
inv_fake.of_SetProvider(inv_fake.MICROSOFT)
inv_fake.of_SetClient("client-123", "s")
inv_fake.of_AddResponse(200, '{"access_token":"at"}')

inv_smtp.of_Authorize(inv_fake.CLIENTCREDENTIALS)
assertEquals("application permission", "https://outlook.office365.com/.default", inv_fake.of_GetParameter(inv_fake.of_LastPost(), "scope"))

// Another flow: the delegated scope (here, with a refresh token instead of the browser)
inv_fake.of_SetRefreshToken("rt")
inv_smtp.of_Authorize(inv_fake.AUTHORIZATIONCODE)
assertEquals("delegated", "https://outlook.office.com/SMTP.Send offline_access", inv_fake.of_GetParameter(inv_fake.of_LastPost(), "scope"))

// The application's scope
inv_fake.of_SetScope("https://outlook.office.com/SMTP.Send")
inv_fake.of_SetRefreshToken("rt")
inv_smtp.of_Authorize(inv_fake.AUTHORIZATIONCODE)
assertEquals("own scope", "https://outlook.office.com/SMTP.Send", inv_fake.of_GetParameter(inv_fake.of_LastPost(), "scope"))

// Google
Destroy inv_smtp
inv_smtp = Create n_smtpclient
of_UseFake()
inv_fake.of_SetProvider(inv_fake.GOOGLE)
inv_fake.of_SetClient("client-g", "secret-g")
inv_fake.of_SetRefreshToken("rt")
inv_fake.of_AddResponse(200, '{"access_token":"at"}')
inv_smtp.of_Authorize(inv_fake.AUTHORIZATIONCODE)
assertEquals("Gmail", "https://mail.google.com/", inv_fake.of_GetScope())

// Other providers: no default
Destroy inv_smtp
inv_smtp = Create n_smtpclient
of_UseFake()
inv_fake.of_SetEndpoints("", "https://idp.example/token", "")
inv_fake.of_SetClient("client-123", "s")
inv_fake.of_AddResponse(200, '{"access_token":"at"}')
inv_smtp.of_Authorize(inv_fake.CLIENTCREDENTIALS)
assertEquals("no default", "", inv_fake.of_GetScope())
end event

event test_setaccesstoken();// A token the application got itself.
assertEquals("empty", -1, inv_smtp.of_SetAccessToken(""))
assertEquals("token", 1, inv_smtp.of_SetAccessToken("tok"))
assertEquals("XOAUTH2", 5, inv_smtp.AuthType)
assertEquals("set", "tok", inv_smtp.XOAuth2AccessToken)
end event

event test_send_authorization_failed();// of_Send doesn't send when no token can be obtained.
of_UseFake()
inv_fake.of_SetEndpoints("", "https://idp.example/token", "")
inv_fake.of_SetClient("client-123")
inv_fake.of_SetFlow(inv_fake.CLIENTCREDENTIALS)
assertEquals("not sent", inv_smtp.AUTHORIZATIONFAILED, inv_smtp.of_Send())
assertEquals("why", "Missing: client secret", inv_smtp.inv_oauth2.of_GetError())
assertEquals("nothing posted", 0, UpperBound(inv_fake.is_posts))
end event

on n_cst_smtpclient_tests.create
call super::create
end on

on n_cst_smtpclient_tests.destroy
call super::destroy
end on
