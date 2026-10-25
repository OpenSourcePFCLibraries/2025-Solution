//objectcomments Unit tests for saving and loading the MRU service's lists (#80; no database needed)
forward
global type n_cst_mru_tests from testcase
end type
end forward

global type n_cst_mru_tests from testcase
event test_empty_list_saved ( )
event test_items_read_back ( )
event test_removed_items_not_read_back ( )
end type
global n_cst_mru_tests n_cst_mru_tests

type variables
Protected:
// The service keeps its lists in an INI file here (it can also use the registry)
string	is_ini
constant string MRU_ID = "pfctest"
end variables

forward prototypes
protected function n_cst_mru of_newservice ()
protected subroutine of_additem (n_cst_mru anv_mru, string as_menuitemname)
end prototypes

protected function n_cst_mru of_newservice ();// A service as an application starts it: it reads the lists saved last (pfc_open),
// and the window registers its id
n_cst_mru	lnv_mru

lnv_mru = Create n_cst_mru
lnv_mru.of_SetUserIniFile(is_ini)
lnv_mru.event pfc_open("")
lnv_mru.of_Register(MRU_ID)
Return lnv_mru
end function

protected subroutine of_additem (n_cst_mru anv_mru, string as_menuitemname);// An item, as a window adds one when the user opens something
n_cst_mruattrib	lnv_item

lnv_item.is_id = MRU_ID
lnv_item.is_classname = "w_pfctest_host"
lnv_item.is_menuitemname = as_menuitemname
lnv_item.is_menuitemkey = as_menuitemname
lnv_item.is_menuitemmhelp = ""
anv_mru.of_AddItem(lnv_item)
end subroutine

event setup;call super::setup;integer	li_file

is_ini = GetCurrentDirectory() + "\pfctest_mru.ini"
FileDelete(is_ini)
// SetProfileString doesn't create a missing file
li_file = FileOpen(is_ini, LineMode!, Write!, LockWrite!, Replace!)
FileClose(li_file)
end event

event teardown;call super::teardown;FileDelete(is_ini)
end event

event test_empty_list_saved();// With nothing in its list, the service still saves the registered id (it used to
// stop at the empty list, and report an error when the application closed)
n_cst_mru	lnv_mru

lnv_mru = of_NewService()
lnv_mru.event pfc_close()
Destroy lnv_mru

assertEquals("registered ids saved", "1", ProfileString(is_ini, "MRU Registered Id", "ItemCount", ""))
assertTrue("the id saved", Pos(ProfileString(is_ini, "MRU Registered Id", "Item1", ""), MRU_ID) > 0)
assertEquals("no items", "", ProfileString(is_ini, "MRU " + MRU_ID, "Item1", ""))
end event

event test_items_read_back();// The items saved when the application closes are in the list when it starts again
n_cst_mru	lnv_mru

lnv_mru = of_NewService()
of_AddItem(lnv_mru, "First")
of_AddItem(lnv_mru, "Second")
lnv_mru.event pfc_close()
Destroy lnv_mru

lnv_mru = of_NewService()
assertTrue("first read back", lnv_mru.of_FindItem("  First", 0) > 0)
assertTrue("second read back", lnv_mru.of_FindItem("  Second", 0) > 0)
Destroy lnv_mru
end event

event test_removed_items_not_read_back();// After the list is emptied (of_Reset), the items saved before don't come back
n_cst_mru	lnv_mru

lnv_mru = of_NewService()
of_AddItem(lnv_mru, "First")
of_AddItem(lnv_mru, "Second")
lnv_mru.event pfc_close()
Destroy lnv_mru

lnv_mru = of_NewService()
lnv_mru.of_Reset(MRU_ID)
lnv_mru.event pfc_close()
Destroy lnv_mru

assertEquals("first cleared", "", ProfileString(is_ini, "MRU " + MRU_ID, "Item1", ""))
assertEquals("second cleared", "", ProfileString(is_ini, "MRU " + MRU_ID, "Item2", ""))
lnv_mru = of_NewService()
assertEquals("not read back", 0, lnv_mru.of_FindItem("  First", 0))
Destroy lnv_mru
end event

on n_cst_mru_tests.create
call super::create
end on

on n_cst_mru_tests.destroy
call super::destroy
end on
