forward
global type n_cst_sortattrib from pfc_n_cst_sortattrib
end type
end forward

global type n_cst_sortattrib from pfc_n_cst_sortattrib
end type

on n_cst_sortattrib.create
TriggerEvent( this, "constructor" )
end on

on n_cst_sortattrib.destroy
TriggerEvent( this, "destructor" )
end on

