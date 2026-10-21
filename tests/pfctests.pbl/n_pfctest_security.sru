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
end prototypes

public function integer of_loadsecurityfortest (string as_object);// Loads the settings for one object, as of_SetSecurity does before applying them.
Return of_LoadSecurity(as_object)
end function

on n_pfctest_security.create
call super::create
end on

on n_pfctest_security.destroy
call super::destroy
end on
