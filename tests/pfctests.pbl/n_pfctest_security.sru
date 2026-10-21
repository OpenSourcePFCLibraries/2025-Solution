//objectcomments Exposes protected n_cst_security functions to the security tests
forward
global type n_pfctest_security from n_cst_security
end type
end forward

global type n_pfctest_security from n_cst_security
end type
global n_pfctest_security n_pfctest_security

forward prototypes
public function integer of_loadsecurityfortest (string as_object)
public function string of_getsystemtypefortest (powerobject apo_object)
public function integer of_setcontrolstatusgenericfortest (graphicobject ago_item, string as_window, string as_itemname)
end prototypes

public function integer of_loadsecurityfortest (string as_object);// Loads the settings for one object, as of_SetSecurity does before applying them.
Return of_LoadSecurity(as_object)
end function

public function string of_getsystemtypefortest (powerobject apo_object);// Exposes of_GetSystemType.
Return of_GetSystemType(apo_object)
end function

public function integer of_setcontrolstatusgenericfortest (graphicobject ago_item, string as_window, string as_itemname);// Exposes of_SetControlStatus_Generic.
Return of_SetControlStatus_Generic(ago_item, as_window, as_itemname)
end function

on n_pfctest_security.create
call super::create
end on

on n_pfctest_security.destroy
call super::destroy
end on
