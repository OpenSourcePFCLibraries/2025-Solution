//objectcomments Unit tests for saving and restoring the grid service's layout (#89; no database needed)
forward
global type n_cst_grid_layout_tests from testcase
end type
end forward

global type n_cst_grid_layout_tests from testcase
event test_saved_for_user ( )
event test_saved_when_destroyed ( )
event test_other_user_has_no_layout ( )
event test_application_level ( )
end type
global n_cst_grid_layout_tests n_cst_grid_layout_tests

type variables
Protected:
// The application keeps preferences per user, in an INI file, and has no application key
string	is_userini
string	is_otheruserini

w_pfctest_host	iw_host
u_dw				idw
end variables

forward prototypes
protected function u_dw of_newgrid ()
protected subroutine of_hidepair (u_dw adw)
protected subroutine of_createfile (string as_file)
end prototypes

protected function u_dw of_newgrid ();// A grid DataWindow on the host window, with the grid service, which restores the
// layout saved last
u_dw	ldw

iw_host.OpenUserObject(ldw)
ldw.DataObject = "d_pfctest_translate"
ldw.of_SetGrid(True)
Return ldw
end function

protected subroutine of_hidepair (u_dw adw);// What the Grid Layout dialog does when the user hides a column and clicks OK
adw.Modify("pair.visible=0")
adw.inv_grid.of_Populate()
end subroutine

protected subroutine of_createfile (string as_file);// An empty file
integer	li_file

li_file = FileOpen(as_file, LineMode!, Write!, LockWrite!, Replace!)
FileClose(li_file)
end subroutine

event setup;call super::setup;is_userini = GetCurrentDirectory() + "\pfctest_grid_user.ini"
is_otheruserini = GetCurrentDirectory() + "\pfctest_grid_other.ini"
FileDelete(is_userini)
FileDelete(is_otheruserini)
// SetProfileString doesn't create a missing file
of_CreateFile(is_userini)
of_CreateFile(is_otheruserini)

gnv_app.of_SetAppPreference(True)
gnv_app.inv_apppref.of_SetUserIniFile(is_userini)

Open(iw_host)
end event

event teardown;call super::teardown;If IsValid(iw_host) Then Close(iw_host)
gnv_app.of_SetAppPreference(False)
FileDelete(is_userini)
FileDelete(is_otheruserini)
end event

event test_saved_for_user();// of_SetGrid(FALSE) saves the layout in the user's file, and of_SetGrid(TRUE) on a fresh
// copy of the DataWindow restores it
idw = of_NewGrid()
assertEquals("visible at first", "1", idw.Describe("pair.visible"))
of_HidePair(idw)
idw.of_SetGrid(False)
assertTrue("saved in the user's file", ProfileString(is_userini, "AppUserPref", "gridlayout.w_pfctest_host.u_dw", "") <> "")

// Back to the design layout, then the service restores the saved one
idw.DataObject = "d_pfctest_translate"
assertEquals("design layout", "1", idw.Describe("pair.visible"))
idw.of_SetGrid(True)
assertEquals("restored: hidden", "0", idw.Describe("pair.visible"))
assertEquals("restored: others visible", "1", idw.Describe("object.visible"))
end event

event test_saved_when_destroyed();// The DataWindow's destructor turns the service off, which saves the layout
u_dw	ldw

ldw = of_NewGrid()
of_HidePair(ldw)
iw_host.CloseUserObject(ldw)

idw = of_NewGrid()
assertEquals("restored after the DataWindow was destroyed", "0", idw.Describe("pair.visible"))
end event

event test_other_user_has_no_layout();// Each user has a layout of their own
idw = of_NewGrid()
of_HidePair(idw)
idw.of_SetGrid(False)
iw_host.CloseUserObject(idw)

gnv_app.inv_apppref.of_SetUserIniFile(is_otheruserini)
idw = of_NewGrid()
assertEquals("another user: the design layout", "1", idw.Describe("pair.visible"))
end event

event test_application_level();// An application without user preferences keeps saving the layout at application level,
// as before: in the application INI file, in a section named after the window
gnv_app.inv_apppref.of_SetUserIniFile("")
gnv_app.inv_apppref.of_SetAppIniFile(is_otheruserini)

idw = of_NewGrid()
of_HidePair(idw)
idw.of_SetGrid(False)
assertTrue("saved in the application file", ProfileString(is_otheruserini, "w_pfctest_host", "u_dw", "") <> "")
assertEquals("not in the user file", "", ProfileString(is_userini, "AppUserPref", "gridlayout.w_pfctest_host.u_dw", ""))

idw.DataObject = "d_pfctest_translate"
idw.of_SetGrid(True)
assertEquals("restored from the application file", "0", idw.Describe("pair.visible"))
end event

on n_cst_grid_layout_tests.create
call super::create
end on

on n_cst_grid_layout_tests.destroy
call super::destroy
end on
