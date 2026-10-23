//objectcomments Drop-down search service that exposes its state, for the drop-down search tests
forward
global type n_pfctest_dropdownsearch from n_cst_dwsrv_dropdownsearch
end type
end forward

global type n_pfctest_dropdownsearch from n_cst_dwsrv_dropdownsearch
end type
global n_pfctest_dropdownsearch n_pfctest_dropdownsearch

forward prototypes
public function string of_gettextprev ()
public function boolean of_getperformsearch ()
end prototypes

public function string of_gettextprev ();Return is_textprev
end function

public function boolean of_getperformsearch ();Return ib_performsearch
end function

on n_pfctest_dropdownsearch.create
call super::create
end on

on n_pfctest_dropdownsearch.destroy
call super::destroy
end on
