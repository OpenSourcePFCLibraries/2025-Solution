//objectcomments Hidden MDI frame, for the status bar service tests
forward
global type w_pfctest_frame from w_frame
end type
end forward

global type w_pfctest_frame from w_frame
boolean visible = false
integer width = 3000
integer height = 1600
string title = "PFC unit test frame"
end type
global w_pfctest_frame w_pfctest_frame

on w_pfctest_frame.create
call super::create
end on

on w_pfctest_frame.destroy
call super::destroy
end on
