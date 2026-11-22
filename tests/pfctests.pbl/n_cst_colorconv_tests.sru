//objectcomments Unit tests for n_cst_colorconv HSV to RGB conversion (no database needed)
forward
global type n_cst_colorconv_tests from testcase
end type
end forward

global type n_cst_colorconv_tests from testcase
event test_hsv2rgb_each_hue_sector ( )
event test_hsv2rgb_grey_when_no_saturation ( )
end type
global n_cst_colorconv_tests n_cst_colorconv_tests

forward prototypes
protected function string of_hsv2rgb (decimal adec_h, decimal adec_s, decimal adec_v)
end prototypes

event test_hsv2rgb_each_hue_sector();// One hue from each of the six sectors of the colour wheel (H * 6 = 0 to 5).
// The hues are chosen so every channel comes out as a whole number.
assertEquals("sector 0", "255,153,0", of_hsv2rgb(0.1, 1, 1))
assertEquals("sector 1", "204,255,0", of_hsv2rgb(0.2, 1, 1))
assertEquals("sector 2", "0,255,102", of_hsv2rgb(0.4, 1, 1))
assertEquals("sector 3", "0,255,255", of_hsv2rgb(0.5, 1, 1))
assertEquals("sector 4", "204,0,255", of_hsv2rgb(0.8, 1, 1))
assertEquals("sector 5", "255,0,153", of_hsv2rgb(0.9, 1, 1))
assertEquals("red", "255,0,0", of_hsv2rgb(0, 1, 1))
assertEquals("hue 1 wraps to red", "255,0,0", of_hsv2rgb(1, 1, 1))
end event

event test_hsv2rgb_grey_when_no_saturation();assertEquals("white", "255,255,255", of_hsv2rgb(0.3, 0, 1))
assertEquals("black", "0,0,0", of_hsv2rgb(0.3, 0, 0))
assertEquals("grey", "102,102,102", of_hsv2rgb(0.7, 0, 0.4))
end event

protected function string of_hsv2rgb (decimal adec_h, decimal adec_s, decimal adec_v);// Converts and returns the result as "r,g,b", or an error message.
n_cst_colorconv		lnv_colorconv
s_hsv_colorattrib		lstr_hsv
s_rgb_colorattrib		lstr_rgb
Integer					li_rc

lstr_hsv.h = adec_h
lstr_hsv.s = adec_s
lstr_hsv.v = adec_v

li_rc = lnv_colorconv.of_hsv2rgb(lstr_hsv, lstr_rgb)
If li_rc <> 1 Then Return "of_hsv2rgb returned " + String(li_rc)

Return String(lstr_rgb.r) + "," + String(lstr_rgb.g) + "," + String(lstr_rgb.b)
end function

on n_cst_colorconv_tests.create
call super::create
end on

on n_cst_colorconv_tests.destroy
call super::destroy
end on
