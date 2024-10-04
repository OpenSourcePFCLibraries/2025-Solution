forward
global type n_cst_zoomattrib from pfc_n_cst_zoomattrib
end type
end forward

global type n_cst_zoomattrib from pfc_n_cst_zoomattrib
end type

on n_cst_zoomattrib.create
TriggerEvent( this, "constructor" )
end on

on n_cst_zoomattrib.destroy
TriggerEvent( this, "destructor" )
end on

