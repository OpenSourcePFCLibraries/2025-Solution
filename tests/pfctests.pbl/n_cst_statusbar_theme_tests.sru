//objectcomments Unit tests for the status bar's theme colors (#77; no database needed)
forward
global type n_cst_statusbar_theme_tests from testcase
end type
end forward

global type n_cst_statusbar_theme_tests from testcase
event test_theme_colors ( )
event test_theme_without_statusbar ( )
event test_missing_file ( )
event test_color_order ( )
event test_applied_theme ( )
end type
global n_cst_statusbar_theme_tests n_cst_statusbar_theme_tests

type variables
Protected:
string	is_folder
n_cst_winsrv_statusbar	inv_statusbar

// A theme that PowerBuilder installs, to apply
constant string DARK_THEME = "C:\Program Files (x86)\Appeon\PowerBuilder 25.0\IDE\theme\Flat Design Dark"
end variables

forward prototypes
protected function string of_writetheme (string as_name, string as_json)
end prototypes

protected function string of_writetheme (string as_name, string as_json);// A theme.json with the given content, in a folder of its own; returns its path
string	ls_folder, ls_file
integer	li_file

ls_folder = is_folder + "\" + as_name
CreateDirectory(ls_folder)
ls_file = ls_folder + "\theme.json"
li_file = FileOpen(ls_file, TextMode!, Write!, LockWrite!, Replace!, EncodingUTF8!)
FileWriteEx(li_file, as_json)
FileClose(li_file)
Return ls_file
end function

event setup;call super::setup;is_folder = GetCurrentDirectory() + "\pfctest_themes"
CreateDirectory(is_folder)
inv_statusbar = Create n_cst_winsrv_statusbar
end event

event teardown;call super::teardown;If IsValid(inv_statusbar) Then Destroy inv_statusbar
If GetTheme() <> "" Then gnv_app.of_ApplyTheme("")
end event

event test_theme_colors();// The statusbar entry of the theme's window section, #RRGGBB
long	ll_background, ll_text
string	ls_file

ls_file = of_WriteTheme("colors", '{"window": {"background-color": "#FFFFFF", "statusbar": {"background-color": "#102030", "text-font": {"color": "#a0b0c0"}}}}')
assertEquals("read", 1, inv_statusbar.of_GetThemeColors(ls_file, ll_background, ll_text))
assertEquals("background", RGB(16, 32, 48), ll_background)
assertEquals("text", RGB(160, 176, 192), ll_text)
end event

event test_theme_without_statusbar();// A theme without status bar colors gives none (-1), and isn't an error
long	ll_background, ll_text
string	ls_file

ls_file = of_WriteTheme("nostatusbar", '{"window": {"background-color": "#FFFFFF"}}')
assertEquals("read", 1, inv_statusbar.of_GetThemeColors(ls_file, ll_background, ll_text))
assertEquals("no background", -1, ll_background)
assertEquals("no text", -1, ll_text)
end event

event test_missing_file();long	ll_background, ll_text

assertEquals("missing file", -1, inv_statusbar.of_GetThemeColors(is_folder + "\none\theme.json", ll_background, ll_text))
assertEquals("no background", -1, ll_background)
end event

event test_color_order();// Without a theme, the system colors; the application's colors come first
long	ll_background, ll_text
string	ls_rgb

If GetTheme() <> "" Then gnv_app.of_ApplyTheme("")
inv_statusbar.of_GetColors(ll_background, ll_text)
RegistryGet("hkey_current_user\control panel\colors", "buttonface", ls_rgb)
If Len(ls_rgb) > 0 Then assertEquals("ButtonFace, as Windows has it", RGB(Integer(Left(ls_rgb, Pos(ls_rgb, " ") - 1)), Integer(Mid(ls_rgb, Pos(ls_rgb, " ") + 1, LastPos(ls_rgb, " ") - Pos(ls_rgb, " ") - 1)), Integer(Mid(ls_rgb, LastPos(ls_rgb, " ") + 1))), ll_background)
assertEquals("Window Text", 33554432, ll_text)

inv_statusbar.of_SetBackgroundColor(RGB(255, 0, 0))
inv_statusbar.of_SetTextColor(RGB(0, 0, 255))
inv_statusbar.of_GetColors(ll_background, ll_text)
assertEquals("the application's background", RGB(255, 0, 0), ll_background)
assertEquals("the application's text", RGB(0, 0, 255), ll_text)
end event

event test_applied_theme();// gnv_app.of_ApplyTheme remembers the theme's folder, where the status bar finds its colors
long	ll_background, ll_text

If Not FileExists(DARK_THEME + "\theme.json") Then Return	// PowerBuilder's themes aren't installed here
assertEquals("applied", 1, gnv_app.of_ApplyTheme(DARK_THEME))
assertEquals("theme file", DARK_THEME + "\theme.json", inv_statusbar.of_GetThemeFile())
inv_statusbar.of_GetColors(ll_background, ll_text)
assertEquals("the theme's background (#262626)", RGB(38, 38, 38), ll_background)
assertEquals("the theme's text (#CCCCCC)", RGB(204, 204, 204), ll_text)

// The application's color still comes first
inv_statusbar.of_SetBackgroundColor(RGB(0, 128, 0))
inv_statusbar.of_GetColors(ll_background, ll_text)
assertEquals("the application's background", RGB(0, 128, 0), ll_background)
assertEquals("the theme's text", RGB(204, 204, 204), ll_text)
end event

on n_cst_statusbar_theme_tests.create
call super::create
end on

on n_cst_statusbar_theme_tests.destroy
call super::destroy
end on
