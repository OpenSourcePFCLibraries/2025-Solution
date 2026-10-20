//objectcomments Hidden window that hosts visual controls created by unit tests
forward
global type w_pfctest_host from window
end type
end forward

global type w_pfctest_host from window
integer width = 2400
integer height = 1400
boolean visible = false
boolean titlebar = true
string title = "PFC unit test host"
boolean controlmenu = true
long backcolor = 67108864
end type
global w_pfctest_host w_pfctest_host

on w_pfctest_host.create
end on

on w_pfctest_host.destroy
end on
