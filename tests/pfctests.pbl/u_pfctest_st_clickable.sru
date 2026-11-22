//objectcomments Label for the u_st tests that takes clicks: overrides lbuttondown
forward
global type u_pfctest_st_clickable from u_pfctest_st_clicks
end type
end forward

global type u_pfctest_st_clickable from u_pfctest_st_clicks
end type
global u_pfctest_st_clickable u_pfctest_st_clickable

event lbuttondown;// Override the ancestor, which ignores clicks
Return 0
end event

on u_pfctest_st_clickable.create
call super::create
end on

on u_pfctest_st_clickable.destroy
call super::destroy
end on
