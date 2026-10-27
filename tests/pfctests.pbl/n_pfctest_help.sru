//objectcomments Help service that records where it would show a help file, for the help service tests
forward
global type n_pfctest_help from n_cst_help
end type
end forward

global type n_pfctest_help from n_cst_help
end type
global n_pfctest_help n_pfctest_help

type variables
Public:
// What of_ShowInApp and of_ShowInViewer were asked to show (they show nothing)
string	is_appurl
string	is_viewerpath
string	is_viewerdestination
integer	ii_appcount
integer	ii_viewercount
end variables

forward prototypes
protected function integer of_showinapp (string as_url)
protected function integer of_showinviewer (string as_path, string as_destination)
public function string of_pathfortest (string as_file)
end prototypes

protected function integer of_showinapp (string as_url);// Records the URL instead of opening the help window
is_appurl = as_url
ii_appcount++
Return 1
end function

protected function integer of_showinviewer (string as_path, string as_destination);// Records the file and the destination instead of starting the PDF viewer
is_viewerpath = as_path
is_viewerdestination = as_destination
ii_viewercount++
Return 1
end function

public function string of_pathfortest (string as_file);Return of_GetPath(as_file)
end function

on n_pfctest_help.create
call super::create
end on

on n_pfctest_help.destroy
call super::destroy
end on
