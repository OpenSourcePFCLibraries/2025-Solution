//objectcomments Unit tests for the language service and n_cst_string.of_Format (no database needed)
forward
global type n_cst_language_tests from testcase
end type
end forward

global type n_cst_language_tests from testcase
event test_format ( )
event test_no_file ( )
event test_load_utf16 ( )
event test_load_utf8_and_ansi ( )
event test_message ( )
event test_message_with_values ( )
event test_captions ( )
event test_translate_window ( )
event test_translate_menu ( )
event test_translate_datastore ( )
event test_pfc_language_file ( )
event test_application_file ( )
end type
global n_cst_language_tests n_cst_language_tests

type variables
Protected:
n_cst_language	inv_language
string			is_file
end variables

forward prototypes
protected function boolean of_writefile (string as_lines[], encoding ae_encoding)
end prototypes

protected function boolean of_writefile (string as_lines[], encoding ae_encoding);// Writes a language file in the test folder and reads it.
Integer	li_file
Long		ll_idx

is_file = GetCurrentDirectory() + "\pfct_language.lng"
FileDelete(is_file)
li_file = FileOpen(is_file, LineMode!, Write!, LockWrite!, Replace!, ae_encoding)
If Not assertTrue("create " + is_file, li_file > 0) Then Return False
For ll_idx = 1 To UpperBound(as_lines)
	FileWrite(li_file, as_lines[ll_idx])
Next
FileClose(li_file)

Return assertEquals("of_SetLanguageFile", 1, inv_language.of_SetLanguageFile(is_file))
end function

event setup;call super::setup;inv_language = Create n_cst_language
end event

event teardown;call super::teardown;If IsValid(inv_language) Then Destroy inv_language
If Len(is_file) > 0 Then FileDelete(is_file)
end event

event test_format();// Placeholders: %s in order, %1 - %9 by position, %% for a percent sign.
n_cst_string	lnv_string
String			ls_parms[], ls_none[]

ls_parms[1] = "3"
ls_parms[2] = "rows"
assertEquals("in order", "Delete these 3 rows?", lnv_string.of_Format("Delete these %s %s?", ls_parms))
assertEquals("by position", "rows: 3", lnv_string.of_Format("%2: %1", ls_parms))
assertEquals("percent", "100% of 3", lnv_string.of_Format("100%% of %s", ls_parms))
assertEquals("missing value", "a 3 b rows c %s", lnv_string.of_Format("a %s b %s c %s", ls_parms))
assertEquals("no values", "Delete %s?", lnv_string.of_Format("Delete %s?", ls_none))
ls_parms[1] = "LIKE '%s%'"
assertEquals("values are not scanned", "SQL: LIKE '%s%'", lnv_string.of_Format("SQL: %s", ls_parms))
assertEquals("trailing percent", "50%", lnv_string.of_Format("50%", ls_none))
end event

event test_no_file();// Without a language file the texts stay as they are.
String	ls_title = "Title", ls_text = "Text"

assertEquals("no default file in the test folder", 0, inv_language.of_GetCount())
assertEquals("missing file", 0, inv_language.of_SetLanguageFile(GetCurrentDirectory() + "\no_such_file.lng"))
assertEquals("of_GetText default", "Ready", inv_language.of_GetText("app_ready", "Ready"))
assertEquals("of_GetMessage", 0, inv_language.of_GetMessage("pfc_x", ls_title, ls_text))
assertEquals("title kept", "Title", ls_title)
assertEquals("text kept", "Text", ls_text)
end event

event test_load_utf16();// The format of PowerBuilder's lang\default.lng: UTF-16, # comments, KEY="text".
String	ls_lines[]

ls_lines[1] = "# Module: PFC"
ls_lines[2] = 'app_ready="Bereit"'
ls_lines[3] = '  App_Spaces  =  "  mit Leerzeichen  "  '
ls_lines[4] = 'app_escapes="Zeile 1~~r~~nZeile 2 ~~"zitiert~~" ~~~~ ~~x"'
ls_lines[5] = "app_unquoted=ohne Anführungszeichen"
ls_lines[6] = ""
ls_lines[7] = 'app_dup="erste"'
ls_lines[8] = 'APP_DUP="zweite"'
ls_lines[9] = 'not an entry'
If Not of_WriteFile(ls_lines, EncodingUTF16LE!) Then Return

assertEquals("entries (duplicates once)", 5, inv_language.of_GetCount())
assertEquals("text", "Bereit", inv_language.of_GetText("app_ready", "Ready"))
assertEquals("keys are not case sensitive", "Bereit", inv_language.of_GetText("APP_READY", "Ready"))
assertEquals("spaces kept inside the quotes", "  mit Leerzeichen  ", inv_language.of_GetText("app_spaces", ""))
assertEquals("escapes", "Zeile 1~r~nZeile 2 ~"zitiert~" ~~ ~~x", inv_language.of_GetText("app_escapes", ""))
assertEquals("unquoted", "ohne Anführungszeichen", inv_language.of_GetText("app_unquoted", ""))
assertEquals("last entry wins", "zweite", inv_language.of_GetText("app_dup", ""))
assertEquals("missing key", "Default", inv_language.of_GetText("app_missing", "Default"))
assertEquals("file", is_file, inv_language.of_GetLanguageFile())
end event

event test_load_utf8_and_ansi();String	ls_lines[]

ls_lines[1] = 'app_word="Größe"'
If Not of_WriteFile(ls_lines, EncodingUTF8!) Then Return
assertEquals("UTF-8", "Größe", inv_language.of_GetText("app_word", ""))

If Not of_WriteFile(ls_lines, EncodingANSI!) Then Return
assertEquals("ANSI", "Größe", inv_language.of_GetText("app_word", ""))
end event

event test_message();// of_GetMessage, as of_MessageBox(as_id, ...) uses it: the text and the optional title.
String	ls_lines[], ls_title, ls_text

ls_lines[1] = 'pfc_x="Übersetzt."'
ls_lines[2] = 'pfc_x.title="Titel"'
ls_lines[3] = 'pfc_values="Löschen: %s?"'
If Not of_WriteFile(ls_lines, EncodingUTF16LE!) Then Return

ls_title = "Title"
ls_text = "Translated."
assertEquals("translated", 1, inv_language.of_GetMessage("pfc_x", ls_title, ls_text))
assertEquals("text", "Übersetzt.", ls_text)
assertEquals("title", "Titel", ls_title)

// An entry with placeholders needs the values: without them the text is kept
ls_title = "Confirm"
ls_text = "Delete row 5?"
assertEquals("placeholders, no values", 0, inv_language.of_GetMessage("pfc_values", ls_title, ls_text))
assertEquals("text kept", "Delete row 5?", ls_text)
assertEquals("no title entry", "Confirm", ls_title)

ls_text = "Kept"
assertEquals("no id", 0, inv_language.of_GetMessage("", ls_title, ls_text))
end event

event test_message_with_values();// of_GetMessage with values, as of_MessageBox(as_id, ..., as_parms[], ...) uses it.
String	ls_lines[], ls_title, ls_text, ls_parms[]

ls_lines[1] = 'pfc_values="%2 von %1 löschen?"'
If Not of_WriteFile(ls_lines, EncodingUTF16LE!) Then Return

ls_parms[1] = "rows"
ls_parms[2] = "3"
ls_text = "Delete %2 %1?"
assertEquals("translated", 1, inv_language.of_GetMessage("pfc_values", ls_title, ls_text, ls_parms))
assertEquals("values placed by position", "3 von rows löschen?", ls_text)

ls_text = "Delete these %s %s?"
assertEquals("no entry", 0, inv_language.of_GetMessage("pfc_other", ls_title, ls_text, ls_parms))
assertEquals("English with the values", "Delete these rows 3?", ls_text)
end event

event test_captions();// Captions are keyed by their English text: "English"="translation".
String	ls_lines[]

ls_lines[1] = '"&Cancel"="&Abbrechen"'
ls_lines[2] = '  "Page Setup"  =  "Seite einrichten"  '
ls_lines[3] = '"Say ~~"Hi~~""="Sag ~~"Hallo~~""'
ls_lines[4] = '"Tab~~tStop"="Tab~~tHalt"'
ls_lines[5] = 'cancel="ID, not a caption"'
If Not of_WriteFile(ls_lines, EncodingUTF16LE!) Then Return

assertEquals("caption", "&Abbrechen", inv_language.of_TranslateText("&Cancel"))
assertEquals("spaces around", "Seite einrichten", inv_language.of_TranslateText("Page Setup"))
assertEquals("quotes", "Sag ~"Hallo~"", inv_language.of_TranslateText("Say ~"Hi~""))
assertEquals("tab", "Tab~tHalt", inv_language.of_TranslateText("Tab~tStop"))
assertEquals("no entry", "Cancel", inv_language.of_TranslateText("Cancel"))
assertEquals("IDs and captions are separate", "ID, not a caption", inv_language.of_GetText("cancel", ""))
assertEquals("empty", "", inv_language.of_TranslateText(""))
end event

event test_translate_window();// A window's title and controls; text the application changed is kept.
w_pfctest_host		lw_host
CommandButton		lcb
StaticText			lst, lst_changed
DropDownListBox	lddlb
String				ls_lines[]

ls_lines[1] = '"PFC unit test host"="PFC Testfenster"'
ls_lines[2] = '"&Cancel"="&Abbrechen"'
ls_lines[3] = '"Name:"="Name:"'
ls_lines[4] = '"Up"="Aufwärts"'
ls_lines[5] = '"Down"="Abwärts"'
ls_lines[6] = '"Margins"="Ränder"'
If Not of_WriteFile(ls_lines, EncodingUTF16LE!) Then Return

Open(lw_host)
lw_host.OpenUserObject(lcb)
lw_host.OpenUserObject(lst)
lw_host.OpenUserObject(lst_changed)
lw_host.OpenUserObject(lddlb)
lcb.Text = "&Cancel"
lst.Text = "Margins"
lst_changed.Text = "Margins for printing"
lddlb.AddItem("Up")
lddlb.AddItem("All")
lddlb.AddItem("Down")
lddlb.SelectItem("Down", 0)

assertEquals("translated", 3, inv_language.of_Translate(lw_host))
assertEquals("title", "PFC Testfenster", lw_host.Title)
assertEquals("button", "&Abbrechen", lcb.Text)
assertEquals("static text", "Ränder", lst.Text)
assertEquals("text changed by the application", "Margins for printing", lst_changed.Text)
// List items are often used as values (w_find's search direction), so they are kept
assertTrue("list item kept", lddlb.FindItem("Up", 0) > 0)
assertEquals("selection kept", "Down", lddlb.Text)
assertEquals("again: nothing left to translate", 0, inv_language.of_Translate(lw_host))
Close(lw_host)
end event

event test_translate_menu();m_dw		lm_dw
String	ls_lines[]

ls_lines[1] = '"&Insert"="&Einfügen"'
ls_lines[2] = '"Inserts a new row"="Fügt eine neue Zeile ein"'
If Not of_WriteFile(ls_lines, EncodingUTF16LE!) Then Return

lm_dw = Create m_dw
assertEquals("translated", 2, inv_language.of_Translate(lm_dw))
assertEquals("text", "&Einfügen", lm_dw.m_table.m_insert.Text)
assertEquals("microhelp", "Fügt eine neue Zeile ein", lm_dw.m_table.m_insert.MicroHelp)
Destroy lm_dw
end event

event test_translate_datastore();// Text objects and the display values of a code table.
n_ds		lds
String	ls_lines[], ls_values

ls_lines[1] = '"Object"="Objekt"'
ls_lines[2] = '"Pair"="Paar ~~"x~~""'
ls_lines[3] = '"VALUE"="WERT"'
If Not of_WriteFile(ls_lines, EncodingUTF16LE!) Then Return

lds = Create n_ds
lds.DataObject = "d_pfctest_translate"
assertEquals("translated", 3, inv_language.of_Translate(lds))
assertEquals("text object", "Objekt", lds.Describe("object_t.Text"))
assertEquals("text with quotes", "Paar ~"x~"", lds.Describe("pair_t.Text"))
assertEquals("not in the file", "Val", lds.Describe("val_t.Text"))
ls_values = lds.Describe("kind.Values")
assertTrue("code table: " + ls_values, Pos(ls_values, "WERT~t2/") > 0 And Pos(ls_values, "OBJECT~t1/") > 0)
Destroy lds
end event

event test_pfc_language_file();// The English language file in the repository (lang\pfc.lng, from
// tools\New-PfcLanguageFile.ps1) can be read and maps each text to itself.
String	ls_folder, ls_file
Integer	li_up

ls_folder = GetCurrentDirectory()
For li_up = 0 To 4
	If FileExists(ls_folder + "\lang\pfc.lng") Then
		ls_file = ls_folder + "\lang\pfc.lng"
		Exit
	End If
	ls_folder = Left(ls_folder, LastPos(ls_folder, "\") - 1)
Next
If Not assertTrue("lang\pfc.lng found above " + GetCurrentDirectory(), ls_file <> "") Then Return

assertEquals("of_SetLanguageFile", 1, inv_language.of_SetLanguageFile(ls_file))
assertTrue("entries: " + String(inv_language.of_GetCount()), inv_language.of_GetCount() > 400)
assertEquals("message", "Please enter a User ID to logon.", inv_language.of_GetText("pfc_logon_enterid", ""))
assertEquals("message title", "Confirm Multiple Delete", inv_language.of_GetText("pfc_rowmanager_confirmmultipledelete.title", ""))
assertEquals("message with values", "Are you sure you want to delete these %s %s?", inv_language.of_GetText("pfc_rowmanager_confirmmultipledelete", ""))
assertEquals("caption", "&Cancel", inv_language.of_TranslateText("&Cancel"))
assertEquals("caption with a shortcut", "&Copy~tCtrl+C", inv_language.of_TranslateText("&Copy~tCtrl+C"))
end event

event test_application_file();// An application's own language file, read after lang\pfc.lng: its entries are added,
// and replace those with the same key.
String	ls_lines[], ls_appfile, ls_files[], ls_empty[]
Integer	li_file

ls_lines[1] = 'pfc_x="PFC text"'
ls_lines[2] = '"&Cancel"="&Abbrechen"'
ls_lines[3] = '"Close"="Schließen"'
If Not of_WriteFile(ls_lines, EncodingUTF16LE!) Then Return

ls_appfile = GetCurrentDirectory() + "\pfct_app.lng"
li_file = FileOpen(ls_appfile, LineMode!, Write!, LockWrite!, Replace!, EncodingUTF16LE!)
If Not assertTrue("create " + ls_appfile, li_file > 0) Then Return
FileWrite(li_file, 'app_saved="Rechnung gespeichert."')
FileWrite(li_file, '"Close"="Beenden"')
FileWrite(li_file, '"&Invoice"="&Rechnung"')
FileClose(li_file)

assertEquals("of_AddLanguageFile", 1, inv_language.of_AddLanguageFile(ls_appfile))
assertEquals("missing file", 0, inv_language.of_AddLanguageFile(ls_appfile + ".none"))
assertEquals("PFC entry kept", "PFC text", inv_language.of_GetText("pfc_x", ""))
assertEquals("PFC caption kept", "&Abbrechen", inv_language.of_TranslateText("&Cancel"))
assertEquals("application entry", "Rechnung gespeichert.", inv_language.of_GetText("app_saved", ""))
assertEquals("application caption", "&Rechnung", inv_language.of_TranslateText("&Invoice"))
assertEquals("application file wins", "Beenden", inv_language.of_TranslateText("Close"))
assertEquals("entries", 5, inv_language.of_GetCount())
assertEquals("files", 2, inv_language.of_GetLanguageFiles(ls_files))
assertEquals("first file", is_file, ls_files[1])
assertEquals("second file", ls_appfile, ls_files[2])
assertEquals("of_GetLanguageFile: the first", is_file, inv_language.of_GetLanguageFile())

// of_SetLanguageFile starts over
assertEquals("of_SetLanguageFile", 1, inv_language.of_SetLanguageFile(ls_appfile))
assertEquals("only the new file", 1, inv_language.of_GetLanguageFiles(ls_files))
assertEquals("PFC entry gone", "", inv_language.of_GetText("pfc_x", ""))
FileDelete(ls_appfile)

assertTrue("default application file: " + inv_language.of_GetDefaultApplicationFile(), &
	Right(inv_language.of_GetDefaultApplicationFile(), 18) = "\lang\pfctests.lng")
end event

on n_cst_language_tests.create
call super::create
end on

on n_cst_language_tests.destroy
call super::destroy
end on
