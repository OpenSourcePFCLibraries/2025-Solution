forward
global type n_cst_returnattrib from pfc_n_cst_returnattrib
end type
end forward

global type n_cst_returnattrib from pfc_n_cst_returnattrib
end type

on n_cst_returnattrib.create
TriggerEvent( this, "constructor" )
end on

on n_cst_returnattrib.destroy
TriggerEvent( this, "destructor" )
end on

