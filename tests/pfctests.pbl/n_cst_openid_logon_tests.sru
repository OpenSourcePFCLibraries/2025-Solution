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

event teardown;call super::teardown;If IsValid(iw_logon) Then Close(iw_logon)
end event

on n_cst_openid_logon_tests.create
call super::create
end on

on n_cst_openid_logon_tests.destroy
call super::destroy
end on
