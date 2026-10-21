//objectcomments Hidden window with a ribbon bar, for the security service tests
forward
global type w_pfctest_ribbon_host from window
end type
type cb_1 from commandbutton within w_pfctest_ribbon_host
end type
type rbb_1 from ribbonbar within w_pfctest_ribbon_host
end type
end forward

global type w_pfctest_ribbon_host from window
integer width = 2400
integer height = 1400
boolean visible = false
boolean titlebar = true
string title = "PFC unit test ribbon host"
boolean controlmenu = true
long backcolor = 67108864
cb_1 cb_1
rbb_1 rbb_1
end type
global w_pfctest_ribbon_host w_pfctest_ribbon_host

on w_pfctest_ribbon_host.create
this.cb_1=create cb_1
this.rbb_1=create rbb_1
this.Control[]={this.cb_1,&
this.rbb_1}
end on

on w_pfctest_ribbon_host.destroy
destroy(this.cb_1)
destroy(this.rbb_1)
end on

type cb_1 from commandbutton within w_pfctest_ribbon_host
integer x = 100
integer y = 700
integer width = 400
integer height = 112
integer taborder = 10
string text = "Button"
end type

type rbb_1 from ribbonbar within w_pfctest_ribbon_host
integer x = 0
integer y = 0
integer width = 2400
integer height = 596
end type
