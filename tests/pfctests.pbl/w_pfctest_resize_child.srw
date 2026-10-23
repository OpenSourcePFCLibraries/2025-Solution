//objectcomments Descendant of w_pfctest_resize that inherits its design size, for the resize service tests
forward
global type w_pfctest_resize_child from w_pfctest_resize
end type
end forward

global type w_pfctest_resize_child from w_pfctest_resize
end type
global w_pfctest_resize_child w_pfctest_resize_child

on w_pfctest_resize_child.create
call super::create
end on

on w_pfctest_resize_child.destroy
call super::destroy
end on
