//objectcomments Unit tests for n_cst_conversion object type conversion (no database needed)
forward
global type n_cst_conversion_tests from testcase
end type
end forward

global type n_cst_conversion_tests from testcase
event test_every_object_type_converts_both_ways ( )
event test_types_added_since_2019 ( )
event test_unknown_and_null ( )
end type
global n_cst_conversion_tests n_cst_conversion_tests

event test_every_object_type_converts_both_ways();// Every type in the runtime's object enumeration must convert to a string and back.
// A type added in a later PowerBuilder release makes this test fail until it is added
// to of_object and of_string.
n_cst_conversion			lnv_conversion
EnumerationDefinition	led_object
Object						le_object
Integer						li_idx, li_count
String						ls_name, ls_missing

led_object = FindTypeDefinition("object")
li_count = UpperBound(led_object.Enumeration)
assertTrue("object enumeration has entries", li_count > 0)

For li_idx = 1 To li_count
	ls_name = Lower(led_object.Enumeration[li_idx].Name)
	If lnv_conversion.of_Object(ls_name, le_object) <> 1 Then
		ls_missing += " of_object(" + ls_name + ")"
	ElseIf lnv_conversion.of_String(le_object) <> ls_name Then
		ls_missing += " of_string(" + ls_name + ")"
	End If
Next

assertEquals("types not converted:" + ls_missing, "", ls_missing)
end event

event test_types_added_since_2019();// A few of the types that of_object used to reject.
n_cst_conversion	lnv_conversion
Object				le_object

assertEquals("httpclient", 1, lnv_conversion.of_Object("HTTPClient", le_object))
assertTrue("httpclient!", le_object = httpclient!)
assertEquals("tabbedbar", 1, lnv_conversion.of_Object("tabbedbar", le_object))
assertEquals("tabbedbar string", "tabbedbar", lnv_conversion.of_String(le_object))
assertEquals("pdfdocument", 1, lnv_conversion.of_Object("pdfdocument", le_object))
assertEquals("pdfdocument string", "pdfdocument", lnv_conversion.of_String(le_object))
end event

event test_unknown_and_null();n_cst_conversion	lnv_conversion
Object				le_object
String				ls_null

SetNull(ls_null)
assertEquals("unknown name", -1, lnv_conversion.of_Object("no_such_type", le_object))
assertEquals("null name", -1, lnv_conversion.of_Object(ls_null, le_object))
end event

on n_cst_conversion_tests.create
call super::create
end on

on n_cst_conversion_tests.destroy
call super::destroy
end on
