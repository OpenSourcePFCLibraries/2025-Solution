//objectcomments Descendant of the sort order indicator service that uses its protected members, for the SortDraw tests (#46)
forward
global type n_pfctest_sortdraw from n_cst_dwsrv_sortdraw
end type
end forward

global type n_pfctest_sortdraw from n_cst_dwsrv_sortdraw
end type
global n_pfctest_sortdraw n_pfctest_sortdraw

type variables
Public:
// TRUE once the overridden of_DrawAscending has run
boolean	ib_drewascending
end variables

forward prototypes
public function long of_getprimarycolorfortest ()
public function string of_getbandfortest ()
public subroutine of_drawascendingfortest ()
protected subroutine of_drawascending (integer vi_x, integer vi_y)
end prototypes

public function long of_getprimarycolorfortest ();// A protected instance variable (it was private)
Return il_primaryLineColor
end function

public function string of_getbandfortest ();Return is_band
end function

public subroutine of_drawascendingfortest ();of_DrawAscending(0, 0)
end subroutine

protected subroutine of_drawascending (integer vi_x, integer vi_y);// Overrides a protected function (it was private)
ib_drewascending = True
end subroutine

on n_pfctest_sortdraw.create
call super::create
end on

on n_pfctest_sortdraw.destroy
call super::destroy
end on
