//objectcomments Unit tests for n_cst_datetime julian to gregorian conversion (no database needed)
forward
global type n_cst_datetime_tests from testcase
end type
end forward

global type n_cst_datetime_tests from testcase
event test_gregorian_leap_year_days ( )
event test_gregorian_common_year_days ( )
event test_gregorian_null ( )
end type
global n_cst_datetime_tests n_cst_datetime_tests

forward prototypes
protected function string of_gregorian (long al_julian)
end prototypes

event test_gregorian_leap_year_days();// The leap-year branch of of_Gregorian handles day 59 (29 February),
// the days after it, and the carry into the next year.
// Day numbers count from 1 January of year 0 (day 0).
assertEquals("2024-01-01", "2024-01-01", of_gregorian(739251))
assertEquals("2024-02-28", "2024-02-28", of_gregorian(739309))
assertEquals("2024-02-29", "2024-02-29", of_gregorian(739310))
assertEquals("2024-03-01", "2024-03-01", of_gregorian(739311))
assertEquals("2024-12-31", "2024-12-31", of_gregorian(739616))
assertEquals("2000-02-29", "2000-02-29", of_gregorian(730544))
assertEquals("2000-12-31", "2000-12-31", of_gregorian(730850))
end event

event test_gregorian_common_year_days();assertEquals("2023-02-28", "2023-02-28", of_gregorian(738944))
assertEquals("2023-03-01", "2023-03-01", of_gregorian(738945))
assertEquals("2023-12-31", "2023-12-31", of_gregorian(739250))
assertEquals("2025-01-01", "2025-01-01", of_gregorian(739617))
end event

event test_gregorian_null();n_cst_datetime	lnv_datetime
Long				ll_null

SetNull(ll_null)
assertTrue("null julian gives a null date", IsNull(lnv_datetime.of_Gregorian(ll_null)))
end event

protected function string of_gregorian (long al_julian);n_cst_datetime	lnv_datetime

Return String(lnv_datetime.of_Gregorian(al_julian), "yyyy-mm-dd")
end function

on n_cst_datetime_tests.create
call super::create
end on

on n_cst_datetime_tests.destroy
call super::destroy
end on
