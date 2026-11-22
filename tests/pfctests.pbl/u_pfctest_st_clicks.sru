//objectcomments Label for the u_st tests: counts clicked and getfocus
forward
global type u_pfctest_st_clicks from u_st
end type
end forward

global type u_pfctest_st_clicks from u_st
end type
global u_pfctest_st_clicks u_pfctest_st_clicks

type variables
Public:
integer	ii_clicked
integer	ii_getfocus
end variables

event clicked;ii_clicked++
end event

event getfocus;call super::getfocus;ii_getfocus++
end event

on u_pfctest_st_clicks.create
call super::create
end on

on u_pfctest_st_clicks.destroy
call super::destroy
end on
