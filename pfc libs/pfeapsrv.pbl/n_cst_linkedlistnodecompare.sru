forward
global type n_cst_linkedlistnodecompare from pfc_n_cst_linkedlistnodecompare
end type
end forward

global type n_cst_linkedlistnodecompare from pfc_n_cst_linkedlistnodecompare
end type
global n_cst_linkedlistnodecompare n_cst_linkedlistnodecompare

on n_cst_linkedlistnodecompare.create
TriggerEvent( this, "constructor" )
end on

on n_cst_linkedlistnodecompare.destroy
TriggerEvent( this, "destructor" )
end on

