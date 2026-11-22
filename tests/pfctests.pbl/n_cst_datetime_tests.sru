//objectcomments Unit tests for n_cst_datetime julian/gregorian conversion (no database needed)
forward
global type n_cst_datetime_tests from testcase
end type
end forward

global type n_cst_datetime_tests from testcase
event test_gregorian_leap_year_days ( )
event test_gregorian_common_year_days ( )
event test_gregorian_null ( )
event test_julian_known_days ( )
event test_julian_round_trip ( )
event test_julian_round_trip_sweep ( )
event test_julian_null ( )
event test_isvalid_before_1000 ( )
event test_year_functions_before_1000 ( )
event test_relativeyear_range ( )
event test_relativemonth_range ( )
end type
global n_cst_datetime_tests n_cst_datetime_tests

forward prototypes
protected function string of_gregorian (long al_julian)
protected function string of_roundtrip (date ad_source)
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

event test_julian_known_days();// of_Julian counts days from 1 January of year 0 (day 0), the same
// epoch as of_Gregorian. Date(0000,01,01) is not a valid PowerBuilder
// date (it gives 1900-01-01), which made of_Julian 1900 years short.
n_cst_datetime	lnv_datetime

assertEquals("2000-01-01", 730485, lnv_datetime.of_Julian(Date(2000,01,01)))
assertEquals("2000-02-29", 730544, lnv_datetime.of_Julian(Date(2000,02,29)))
assertEquals("2023-01-01", 738886, lnv_datetime.of_Julian(Date(2023,01,01)))
assertEquals("2023-12-31", 739250, lnv_datetime.of_Julian(Date(2023,12,31)))
assertEquals("2024-01-01", 739251, lnv_datetime.of_Julian(Date(2024,01,01)))
assertEquals("2024-02-29", 739310, lnv_datetime.of_Julian(Date(2024,02,29)))
assertEquals("2025-01-01", 739617, lnv_datetime.of_Julian(Date(2025,01,01)))
assertEquals("0001-01-01", 366, lnv_datetime.of_Julian(Date(0001,01,01)))
assertEquals("0004-01-01", 1461, lnv_datetime.of_Julian(Date(0004,01,01)))
assertEquals("0004-02-29", 1520, lnv_datetime.of_Julian(Date(0004,02,29)))
assertEquals("1900-01-01", 693961, lnv_datetime.of_Julian(Date(1900,01,01)))
end event

event test_julian_round_trip();assertEquals("0001-01-01", "0001-01-01", of_roundtrip(Date(0001,01,01)))
assertEquals("0003-12-31", "0003-12-31", of_roundtrip(Date(0003,12,31)))
assertEquals("0004-02-29", "0004-02-29", of_roundtrip(Date(0004,02,29)))
assertEquals("0100-03-01", "0100-03-01", of_roundtrip(Date(0100,03,01)))
assertEquals("0400-02-29", "0400-02-29", of_roundtrip(Date(0400,02,29)))
assertEquals("0999-12-31", "0999-12-31", of_roundtrip(Date(0999,12,31)))
assertEquals("1000-01-01", "1000-01-01", of_roundtrip(Date(1000,01,01)))
assertEquals("1600-02-29", "1600-02-29", of_roundtrip(Date(1600,02,29)))
assertEquals("1899-12-31", "1899-12-31", of_roundtrip(Date(1899,12,31)))
assertEquals("1900-01-01", "1900-01-01", of_roundtrip(Date(1900,01,01)))
assertEquals("1900-02-28", "1900-02-28", of_roundtrip(Date(1900,02,28)))
assertEquals("1900-03-01", "1900-03-01", of_roundtrip(Date(1900,03,01)))
assertEquals("1999-12-31", "1999-12-31", of_roundtrip(Date(1999,12,31)))
assertEquals("2000-01-01", "2000-01-01", of_roundtrip(Date(2000,01,01)))
assertEquals("2000-02-29", "2000-02-29", of_roundtrip(Date(2000,02,29)))
assertEquals("2023-01-01", "2023-01-01", of_roundtrip(Date(2023,01,01)))
assertEquals("2024-01-01", "2024-01-01", of_roundtrip(Date(2024,01,01)))
assertEquals("2024-02-29", "2024-02-29", of_roundtrip(Date(2024,02,29)))
assertEquals("2024-12-31", "2024-12-31", of_roundtrip(Date(2024,12,31)))
assertEquals("2100-03-01", "2100-03-01", of_roundtrip(Date(2100,03,01)))
assertEquals("2999-12-31", "2999-12-31", of_roundtrip(Date(2999,12,31)))
end event

event test_julian_round_trip_sweep();// Every 13th day from 0001-01-01 to 3000-12-31, plus every day of
// 0001-0005 and 1899-2001, must survive of_Julian -> of_Gregorian unchanged.
// Only the first mismatch is reported.
n_cst_datetime	lnv_datetime
Date				ld_day, ld_end
Long				ll_expected, ll_step
String			ls_expected, ls_actual

ld_day = Date(0001,01,01)
ld_end = Date(3000,12,31)
ll_expected = lnv_datetime.of_Julian(ld_day)
Do While ld_day <= ld_end
	ls_expected = String(ld_day, "yyyy-mm-dd")
	ls_actual = of_roundtrip(ld_day)
	If ls_actual <> ls_expected Then
		assertEquals("round trip " + ls_expected, ls_expected, ls_actual)
		Return
	End If
	If lnv_datetime.of_Julian(ld_day) <> ll_expected Then
		assertEquals("day number " + ls_expected, ll_expected, lnv_datetime.of_Julian(ld_day))
		Return
	End If
	If (ld_day >= Date(1899,01,01) And ld_day <= Date(2001,12,31)) Or ld_day <= Date(0005,12,31) Then
		ll_step = 1
	Else
		ll_step = 13
	End If
	ld_day = RelativeDate(ld_day, ll_step)
	ll_expected += ll_step
Loop
assertTrue("sweep reached the end", ld_day > ld_end)
end event

event test_julian_null();n_cst_datetime	lnv_datetime
Date				ld_null

SetNull(ld_null)
assertTrue("null date gives a null day number", IsNull(lnv_datetime.of_Julian(ld_null)))
end event

event test_isvalid_before_1000();// PowerBuilder's Year() returns -1 for years before 1000, which made
// of_IsValid reject valid dates such as 0001-01-01 (issue #175).
n_cst_datetime	lnv_datetime

assertTrue("0001-01-01", lnv_datetime.of_IsValid(Date(0001,01,01)))
assertTrue("0050-06-01", lnv_datetime.of_IsValid(Date(0050,06,01)))
assertTrue("0999-12-31", lnv_datetime.of_IsValid(Date(0999,12,31)))
assertTrue("1000-01-01", lnv_datetime.of_IsValid(Date(1000,01,01)))
assertTrue("datetime 0001-01-01", lnv_datetime.of_IsValid(DateTime(Date(0001,01,01), Time(12,0,0))))
end event

event test_year_functions_before_1000();n_cst_datetime	lnv_datetime

assertEquals("julian day number 0001-12-31", 365, lnv_datetime.of_JulianDayNumber(Date(0001,12,31)))
assertEquals("julian day number 0004-12-31", 366, lnv_datetime.of_JulianDayNumber(Date(0004,12,31)))
assertEquals("julian day number 2024-03-01", 61, lnv_datetime.of_JulianDayNumber(Date(2024,03,01)))
assertTrue("0004 is a leap year", lnv_datetime.of_IsLeapYear(Date(0004,06,01)))
assertFalse("0100 is not a leap year", lnv_datetime.of_IsLeapYear(Date(0100,06,01)))
assertTrue("0400 is a leap year", lnv_datetime.of_IsLeapYear(Date(0400,06,01)))
assertEquals("first day of month", "0500-02-01", String(lnv_datetime.of_FirstDayOfMonth(Date(0500,02,10)), "yyyy-mm-dd"))
assertEquals("last day of month 0500-02", "0500-02-28", String(lnv_datetime.of_LastDayOfMonth(Date(0500,02,10)), "yyyy-mm-dd"))
assertEquals("last day of month 0400-02", "0400-02-29", String(lnv_datetime.of_LastDayOfMonth(Date(0400,02,10)), "yyyy-mm-dd"))
assertEquals("relative year", "1000-06-15", String(lnv_datetime.of_RelativeYear(Date(0999,06,15), 1), "yyyy-mm-dd"))
assertEquals("relative month", "1000-01-15", String(lnv_datetime.of_RelativeMonth(Date(0999,12,15), 1), "yyyy-mm-dd"))
assertEquals("years after", 2, lnv_datetime.of_YearsAfter(Date(0999,06,15), Date(1001,06,15)))
assertEquals("months after", 24, lnv_datetime.of_MonthsAfter(Date(0999,06,15), Date(1001,06,15)))
assertEquals("week number", 1, lnv_datetime.of_WeekNumber(Date(0500,01,01)))
end event

event test_relativeyear_range();// Date() returns 1900-01-01 for years outside 0001-9999, so a result
// outside that range must come back as NULL, not 1900-01-01 (issue #177).
n_cst_datetime	lnv_datetime

assertEquals("just inside the low end", "0001-06-15", String(lnv_datetime.of_RelativeYear(Date(0005,06,15), -4), "yyyy-mm-dd"))
assertTrue("year 0000 is null", IsNull(lnv_datetime.of_RelativeYear(Date(0005,06,15), -5)))
assertTrue("negative year is null", IsNull(lnv_datetime.of_RelativeYear(Date(0005,06,15), -10)))
assertEquals("just inside the high end", "9999-01-01", String(lnv_datetime.of_RelativeYear(Date(9998,01,01), 1), "yyyy-mm-dd"))
assertTrue("year 10000 is null", IsNull(lnv_datetime.of_RelativeYear(Date(9999,01,01), 1)))
assertTrue("huge positive offset is null", IsNull(lnv_datetime.of_RelativeYear(Date(2024,01,01), 2000000000)))
assertTrue("huge negative offset is null", IsNull(lnv_datetime.of_RelativeYear(Date(2024,01,01), -2000000000)))
assertEquals("29 February to a common year at the low end", "0001-02-28", String(lnv_datetime.of_RelativeYear(Date(0004,02,29), -3), "yyyy-mm-dd"))
assertEquals("ordinary offset unchanged", "2025-02-28", String(lnv_datetime.of_RelativeYear(Date(2024,02,29), 1), "yyyy-mm-dd"))
end event

event test_relativemonth_range();n_cst_datetime	lnv_datetime

assertEquals("just inside the low end", "0001-01-15", String(lnv_datetime.of_RelativeMonth(Date(0001,02,15), -1), "yyyy-mm-dd"))
assertTrue("December 0000 is null", IsNull(lnv_datetime.of_RelativeMonth(Date(0001,01,15), -1)))
assertTrue("negative year is null", IsNull(lnv_datetime.of_RelativeMonth(Date(0001,01,15), -120)))
assertEquals("just inside the high end", "9999-12-15", String(lnv_datetime.of_RelativeMonth(Date(9999,11,15), 1), "yyyy-mm-dd"))
assertTrue("January 10000 is null", IsNull(lnv_datetime.of_RelativeMonth(Date(9999,12,15), 1)))
assertTrue("huge positive offset is null", IsNull(lnv_datetime.of_RelativeMonth(Date(2024,01,15), 2000000000)))
assertTrue("huge negative offset is null", IsNull(lnv_datetime.of_RelativeMonth(Date(2024,01,15), -2000000000)))
assertEquals("ordinary offset unchanged", "2024-02-29", String(lnv_datetime.of_RelativeMonth(Date(2024,01,31), 1), "yyyy-mm-dd"))
assertEquals("ordinary negative offset unchanged", "2023-11-30", String(lnv_datetime.of_RelativeMonth(Date(2024,01,31), -2), "yyyy-mm-dd"))
end event

protected function string of_gregorian (long al_julian);n_cst_datetime	lnv_datetime

Return String(lnv_datetime.of_Gregorian(al_julian), "yyyy-mm-dd")
end function

protected function string of_roundtrip (date ad_source);n_cst_datetime	lnv_datetime

Return String(lnv_datetime.of_Gregorian(lnv_datetime.of_Julian(ad_source)), "yyyy-mm-dd")
end function

on n_cst_datetime_tests.create
call super::create
end on

on n_cst_datetime_tests.destroy
call super::destroy
end on
