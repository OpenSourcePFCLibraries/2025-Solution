//objectcomments Unit tests for the help service (PDF help in the application or the PDF viewer); nothing is shown
forward
global type n_cst_help_tests from testcase
end type
end forward

global type n_cst_help_tests from testcase
event test_viewer ( )
event test_dialoghelpfile ( )
event test_destination ( )
event test_url ( )
event test_viewercommand ( )
event test_compiledhelp ( )
event test_path ( )
event test_showhelp_inapp ( )
event test_showhelp_viewer ( )
event test_showhelp_missing ( )
end type
global n_cst_help_tests n_cst_help_tests

type variables
Protected:
n_pfctest_help	inv_help
// A PDF help file in the current folder, for the tests that show one
string	is_file
end variables

event setup;call super::setup;integer	li_file

inv_help = Create n_pfctest_help
is_file = GetCurrentDirectory() + "\pfct_help.pdf"
li_file = FileOpen(is_file, LineMode!, Write!, LockWrite!, Replace!)
FileWrite(li_file, "%PDF-1.7")
FileClose(li_file)
end event

event teardown;call super::teardown;If IsValid(inv_help) Then Destroy inv_help
If Len(is_file) > 0 Then FileDelete(is_file)
end event

event test_viewer();// Help is shown in the application unless the PDF viewer is chosen.
assertEquals("default", inv_help.INAPP, inv_help.of_GetViewer())
assertEquals("PDF viewer", 1, inv_help.of_SetViewer(inv_help.PDFVIEWER))
assertEquals("PDF viewer set", inv_help.PDFVIEWER, inv_help.of_GetViewer())
assertEquals("invalid", -1, inv_help.of_SetViewer(3))
assertEquals("invalid keeps the viewer", inv_help.PDFVIEWER, inv_help.of_GetViewer())
assertEquals("in the application", 1, inv_help.of_SetViewer(inv_help.INAPP))
assertEquals("in the application set", inv_help.INAPP, inv_help.of_GetViewer())
end event

event test_dialoghelpfile();// The PFC dialog help is pfcdlg.pdf unless the application chooses another file.
string	ls_null

SetNull(ls_null)
assertEquals("default", "pfcdlg.pdf", inv_help.of_GetDialogHelpFile())
assertEquals("set", 1, inv_help.of_SetDialogHelpFile(" help\dialogs.pdf "))
assertEquals("set, trimmed", "help\dialogs.pdf", inv_help.of_GetDialogHelpFile())
assertEquals("empty", -1, inv_help.of_SetDialogHelpFile(""))
assertEquals("null", -1, inv_help.of_SetDialogHelpFile(ls_null))
assertEquals("kept", "help\dialogs.pdf", inv_help.of_GetDialogHelpFile())
end event

event test_destination();// A topic number's destination, as the help builds name them.
assertEquals("topic", "topic_1010", inv_help.of_GetDestination(1010))
assertEquals("general topic", "topic_1", inv_help.of_GetDestination(1))
assertEquals("no topic", "", inv_help.of_GetDestination(0))
assertEquals("negative", "", inv_help.of_GetDestination(-5))
end event

event test_url();// The file: URL of a help file, with its destination.  The characters that mean something
// in a URL are escaped, and a destination keeps only the characters a name can have.
assertEquals("with destination", "file:///C:/Program%20Files/App/help.pdf#nameddest=w_find", &
	inv_help.of_GetURL("C:\Program Files\App\help.pdf", "w_find"))
assertEquals("no destination", "file:///C:/App/help.pdf", inv_help.of_GetURL("C:\App\help.pdf", ""))
assertEquals("escaped", "file:///C:/a%23b%25c%3Fd/help.pdf#nameddest=topic_1010", &
	inv_help.of_GetURL("C:\a#b%c?d\help.pdf", "topic_1010"))
assertEquals("UNC path", "file://server/share/help.pdf#nameddest=x", inv_help.of_GetURL("\\server\share\help.pdf", "x"))
assertEquals("destination cleaned", "file:///C:/help.pdf#nameddest=Filtersimple", inv_help.of_GetURL("C:\help.pdf", "Filter, simple"))
assertEquals("nothing left of the destination", "file:///C:/help.pdf", inv_help.of_GetURL("C:\help.pdf", "&?#"))
assertEquals("dots and dashes", "file:///C:/help.pdf#nameddest=a-b.c_d", inv_help.of_GetURL("C:\help.pdf", "a-b.c_d"))
end event

event test_viewercommand();// The command line that opens a PDF file at a destination in each viewer PFC knows.
string	ls_file

ls_file = "C:\App\help.pdf"
assertEquals("Edge", '"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" "file:///C:/App/help.pdf#nameddest=w_find"', &
	inv_help.of_GetViewerCommand("C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe", ls_file, "w_find"))
assertEquals("Chrome", '"C:\Chrome\chrome.exe" "file:///C:/App/help.pdf#nameddest=w_find"', &
	inv_help.of_GetViewerCommand("C:\Chrome\chrome.exe", ls_file, "w_find"))
assertEquals("Firefox, no destination", '"C:\Firefox\FIREFOX.EXE" "file:///C:/App/help.pdf"', &
	inv_help.of_GetViewerCommand("C:\Firefox\FIREFOX.EXE", ls_file, ""))
assertEquals("Acrobat", '"C:\Adobe\Acrobat.exe" /A "nameddest=topic_1010" "C:\App\help.pdf"', &
	inv_help.of_GetViewerCommand("C:\Adobe\Acrobat.exe", ls_file, "topic_1010"))
assertEquals("Acrobat Reader", '"C:\Adobe\AcroRd32.exe" /A "nameddest=w_zoom" "C:\App\help.pdf"', &
	inv_help.of_GetViewerCommand("C:\Adobe\AcroRd32.exe", ls_file, "w_zoom"))
assertEquals("Acrobat, no destination", '"C:\Adobe\Acrobat.exe" "C:\App\help.pdf"', &
	inv_help.of_GetViewerCommand("C:\Adobe\Acrobat.exe", ls_file, ""))
assertEquals("SumatraPDF", '"C:\Sumatra\SumatraPDF.exe" -named-dest w_find "C:\App\help.pdf"', &
	inv_help.of_GetViewerCommand("C:\Sumatra\SumatraPDF.exe", ls_file, "w_find"))
assertEquals("destination cleaned", '"C:\Adobe\Acrobat.exe" /A "nameddest=wfindcalc" "C:\App\help.pdf"', &
	inv_help.of_GetViewerCommand("C:\Adobe\Acrobat.exe", ls_file, 'w"find & calc'))
assertEquals("unknown viewer", "", inv_help.of_GetViewerCommand("C:\Other\viewer.exe", ls_file, "w_find"))
end event

event test_compiledhelp();// Compiled help files are shown with ShowHelp; any other file is a PDF file.
assertTrue("chm", inv_help.of_IsCompiledHelp("pfcexamp.chm"))
assertTrue("CHM", inv_help.of_IsCompiledHelp("C:\Help\PFCDLG.CHM"))
assertTrue("hlp", inv_help.of_IsCompiledHelp("old.hlp"))
assertFalse("pdf", inv_help.of_IsCompiledHelp("pfcdlg.pdf"))
assertFalse("no extension", inv_help.of_IsCompiledHelp("help"))
end event

event test_path();// A help file without a path is found in the current folder; one with a path must exist.
assertEquals("current folder", is_file, inv_help.of_PathForTest("pfct_help.pdf"))
assertEquals("full path", is_file, inv_help.of_PathForTest(is_file))
assertEquals("missing", "", inv_help.of_PathForTest("pfct_no_such_help.pdf"))
assertEquals("missing full path", "", inv_help.of_PathForTest("C:\pfct_no_such_folder\help.pdf"))
assertEquals("empty", "", inv_help.of_PathForTest("  "))
end event

event test_showhelp_inapp();// In the application, the help window is given the file's URL with the destination.
assertEquals("destination", 1, inv_help.of_ShowHelp("pfct_help.pdf", "w_find"))
assertEquals("destination URL", inv_help.of_GetURL(is_file, "w_find"), inv_help.is_appurl)
assertEquals("topic", 1, inv_help.of_ShowHelp("pfct_help.pdf", 1010))
assertEquals("topic URL", inv_help.of_GetURL(is_file, "topic_1010"), inv_help.is_appurl)
assertEquals("start", 1, inv_help.of_ShowHelp("pfct_help.pdf"))
assertEquals("start URL", inv_help.of_GetURL(is_file, ""), inv_help.is_appurl)
inv_help.of_SetDialogHelpFile("pfct_help.pdf")
assertEquals("dialog help", 1, inv_help.of_ShowDialogHelp("w_sortmulti"))
assertEquals("dialog help URL", inv_help.of_GetURL(is_file, "w_sortmulti"), inv_help.is_appurl)
assertEquals("shown in the application", 4, inv_help.ii_appcount)
assertEquals("not in the PDF viewer", 0, inv_help.ii_viewercount)
end event

event test_showhelp_viewer();// In the PDF viewer, the viewer is given the file and the destination.
inv_help.of_SetViewer(inv_help.PDFVIEWER)
assertEquals("destination", 1, inv_help.of_ShowHelp("pfct_help.pdf", "w_find"))
assertEquals("path", is_file, inv_help.is_viewerpath)
assertEquals("destination given", "w_find", inv_help.is_viewerdestination)
assertEquals("topic", 1, inv_help.of_ShowHelp("pfct_help.pdf", 1010))
assertEquals("topic destination", "topic_1010", inv_help.is_viewerdestination)
assertEquals("cleaned", 1, inv_help.of_ShowHelp("pfct_help.pdf", "w find?"))
assertEquals("cleaned destination", "wfind", inv_help.is_viewerdestination)
assertEquals("shown in the PDF viewer", 3, inv_help.ii_viewercount)
assertEquals("not in the application", 0, inv_help.ii_appcount)
end event

event test_showhelp_missing();// A help file that doesn't exist isn't shown.
string	ls_null

SetNull(ls_null)
assertEquals("missing", -1, inv_help.of_ShowHelp("pfct_no_such_help.pdf", "w_find"))
assertEquals("missing topic", -1, inv_help.of_ShowHelp("pfct_no_such_help.pdf", 1010))
inv_help.of_SetDialogHelpFile("pfct_no_such_help.pdf")
assertEquals("missing dialog help", -1, inv_help.of_ShowDialogHelp("w_find"))
assertEquals("null destination", -1, inv_help.of_ShowHelp("pfct_help.pdf", ls_null))
assertEquals("nothing shown", 0, inv_help.ii_appcount + inv_help.ii_viewercount)
end event

on n_cst_help_tests.create
call super::create
end on

on n_cst_help_tests.destroy
call super::destroy
end on
