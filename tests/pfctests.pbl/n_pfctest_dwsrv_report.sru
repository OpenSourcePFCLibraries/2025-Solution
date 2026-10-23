//objectcomments DataWindow report service that exposes of_GetTextSizePos, for the text size tests
forward
global type n_pfctest_dwsrv_report from n_cst_dwsrv_report
end type
end forward

global type n_pfctest_dwsrv_report from n_cst_dwsrv_report
end type
global n_pfctest_dwsrv_report n_pfctest_dwsrv_report

forward prototypes
public function integer of_gettextsizefortest (string as_text, string as_fontface, integer ai_fontsize, ref integer ai_height, ref integer ai_width)
end prototypes

public function integer of_gettextsizefortest (string as_text, string as_fontface, integer ai_fontsize, ref integer ai_height, ref integer ai_width);// The size only (no alignment, so no position)
alignment	lal_none
vtextalign	lvta_none
integer		li_x, li_y

SetNull(lal_none)
SetNull(lvta_none)
Return of_GetTextSizePos(as_text, "header", lal_none, lvta_none, False, False, False, &
	as_fontface, ai_fontsize, ai_height, ai_width, li_x, li_y)
end function

on n_pfctest_dwsrv_report.create
call super::create
end on

on n_pfctest_dwsrv_report.destroy
call super::destroy
end on
