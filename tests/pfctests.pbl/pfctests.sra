//objectcomments PFC unit test runner (PBUnit).  Runs the discovered test cases and writes the results.
forward
global n_tr sqlca
global dynamicdescriptionarea sqlda
global dynamicstagingarea sqlsa
global error error
global n_msg message
end forward

global variables
/*  Application Manager  */
n_cst_appmanager gnv_app
end variables

global type pfctests from application
 string appruntimeversion = "25.1.0.6430"
integer highdpimode = 0
end type
global pfctests pfctests

on pfctests.create
appname = "pfctests"
message = create n_msg
sqlca = create n_tr
sqlda = create dynamicdescriptionarea
sqlsa = create dynamicstagingarea
error = create error
end on

on pfctests.destroy
destroy( sqlca )
destroy( sqlda )
destroy( sqlsa )
destroy( error )
destroy( message )
end on

event open;//////////////////////////////////////////////////////////////////////////////
//
//	Runs the PBUnit tests (see tests\framework\README.md for the command
//	line), writes the results, and ends the process with exit code
//	0 (pass), 1 (failures) or 2 (problems).
//
//////////////////////////////////////////////////////////////////////////////
n_pbunit_runner	lnv_runner
Integer				li_exitcode

gnv_app = create n_cst_appmanager

lnv_runner = create n_pbunit_runner
li_exitcode = lnv_runner.of_Run(CommandParm())

// of_Exit ends the process immediately, so the close event will not run.
Destroy gnv_app
lnv_runner.of_Exit(li_exitcode)
end event

event close;If IsValid ( gnv_app ) Then Destroy gnv_app
end event

event systemerror;// Route the error to the running test case, if there is one.
If f_catchsystemerror() = 1 Then Return

Halt Close
end event
