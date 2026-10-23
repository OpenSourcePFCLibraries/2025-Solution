//objectcomments Unit tests for the size of text with several lines (#41, #42; no database needed)
forward
global type n_cst_textsize_tests from testcase
end type
end forward

global type n_cst_textsize_tests from testcase
event test_single_line ( )
event test_two_lines ( )
event test_widest_line ( )
event test_line_break_kinds ( )
event test_empty_line ( )
event test_report_widest_line ( )
end type
global n_cst_textsize_tests n_cst_textsize_tests

type variables
Protected:
Constant String FONT = "Arial"
Constant Integer SIZE = 10
// More characters, but narrower than the second line in a proportional font
Constant String NARROW = "iiiiiiiiii"
Constant String WIDE = "WWWWWW"

w_pfctest_host			iw_host
n_cst_platformunicode	inv_platform
end variables

forward prototypes
protected function integer of_measure (string as_text, ref integer ai_height, ref integer ai_width)
end prototypes

protected function integer of_measure (string as_text, ref integer ai_height, ref integer ai_width);window	lw_host

lw_host = iw_host
Return inv_platform.of_GetTextSize(lw_host, as_text, FONT, SIZE, False, False, False, ai_height, ai_width)
end function

event setup;call super::setup;Open(iw_host)
inv_platform = Create n_cst_platformunicode
end event

event teardown;call super::teardown;If IsValid(inv_platform) Then Destroy inv_platform
If IsValid(iw_host) Then Close(iw_host)
end event

event test_single_line();integer	li_height, li_width

assertEquals("rc", 1, of_Measure("Hello", li_height, li_width))
assertTrue("height " + String(li_height), li_height > 0)
assertTrue("width " + String(li_width), li_width > 0)
end event

event test_two_lines();// Two lines: twice as high as one, as wide as the wider.
integer	li_h1, li_w1, li_h2, li_w2, li_height, li_width

of_Measure("Hello", li_h1, li_w1)
of_Measure("Hi", li_h2, li_w2)
assertEquals("rc", 1, of_Measure("Hello~r~nHi", li_height, li_width))
assertEquals("height", li_h1 + li_h2, li_height)
assertEquals("width", li_w1, li_width)
end event

event test_widest_line();// The widest line, not the one with the most characters.
integer	li_hn, li_wn, li_hw, li_ww, li_height, li_width

of_Measure(NARROW, li_hn, li_wn)
of_Measure(WIDE, li_hw, li_ww)
If Not assertTrue("the font is proportional: " + String(li_wn) + " < " + String(li_ww), li_wn < li_ww) Then Return
of_Measure(NARROW + "~r~n" + WIDE, li_height, li_width)
assertEquals("width", li_ww, li_width)
end event

event test_line_break_kinds();// ~r~n, ~n and ~r each start a new line.
integer	li_h, li_w, li_height, li_width

of_Measure("a~r~nb", li_h, li_w)
of_Measure("a~nb", li_height, li_width)
assertEquals("~~n height", li_h, li_height)
assertEquals("~~n width", li_w, li_width)
of_Measure("a~rb", li_height, li_width)
assertEquals("~~r height", li_h, li_height)
end event

event test_empty_line();// An empty line counts in the height, not in the width.
integer	li_h1, li_w1, li_height, li_width

of_Measure("a", li_h1, li_w1)
of_Measure("a~r~n~r~na", li_height, li_width)
assertEquals("height", 3 * li_h1, li_height)
assertEquals("width", li_w1, li_width)
end event

event test_report_widest_line();// The report service sizes a text object by its widest line (#42).
u_dw						ldw
n_pfctest_dwsrv_report	lnv_report
integer					li_lines, li_height, li_width, li_hw, li_ww, li_h1, li_w1

iw_host.OpenUserObject(ldw)
ldw.DataObject = "d_pfctest_linkage_master"
lnv_report = Create n_pfctest_dwsrv_report
lnv_report.of_SetRequestor(ldw)

li_lines = lnv_report.of_GetTextSizeForTest(NARROW + "~r~n" + WIDE, FONT, SIZE, li_height, li_width)
assertEquals("lines", 2, li_lines)
// The DataWindow is in PowerBuilder units
of_Measure(WIDE + " ", li_hw, li_ww)
assertEquals("width", PixelsToUnits(li_ww, XPixelsToUnits!), li_width)
of_Measure(WIDE + " ~r~n" + WIDE + " ", li_h1, li_w1)
assertEquals("height", PixelsToUnits(li_h1, YPixelsToUnits!), li_height)
Destroy lnv_report
end event

on n_cst_textsize_tests.create
call super::create
end on

on n_cst_textsize_tests.destroy
call super::destroy
end on
