//objectcomments Status bar service that exposes its window, for the status bar tests
forward
global type n_pfctest_statusbar from n_cst_winsrv_statusbar
end type
end forward

global type n_pfctest_statusbar from n_cst_winsrv_statusbar
end type
global n_pfctest_statusbar n_pfctest_statusbar

forward prototypes
public function w_statusbar of_getwindowfortest ()
end prototypes

public function w_statusbar of_getwindowfortest ();Return iw_statusbar
end function

on n_pfctest_statusbar.create
call super::create
end on

on n_pfctest_statusbar.destroy
call super::destroy
end on
