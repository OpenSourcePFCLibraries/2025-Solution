//objectcomments Hidden w_master with a known design size, for the resize service tests
forward
global type w_pfctest_resize from w_master
end type
end forward

global type w_pfctest_resize from w_master
integer width = 2000
integer height = 1200
boolean visible = false
string title = "PFC resize test"
boolean resizable = true
end type
global w_pfctest_resize w_pfctest_resize

forward prototypes
public subroutine of_getorigsizefortest (ref integer ai_width, ref integer ai_height)
end prototypes

public subroutine of_getorigsizefortest (ref integer ai_width, ref integer ai_height);of_GetOrigSize(ai_width, ai_height)
end subroutine

on w_pfctest_resize.create
call super::create
end on

on w_pfctest_resize.destroy
call super::destroy
end on
