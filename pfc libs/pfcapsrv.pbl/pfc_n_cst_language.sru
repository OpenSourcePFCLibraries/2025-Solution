//objectcomments PFC Language service
forward
global type pfc_n_cst_language from n_base
end type
end forward

global type pfc_n_cst_language from n_base
end type
global pfc_n_cst_language pfc_n_cst_language

type prototypes
Function ulong GetModuleFileNameW(ulong hModule, ref string lpFilename, ulong nSize) Library "kernel32.dll"
end prototypes

type variables
Public:
// File name of the PFC language file in the "lang" folder of the application
Constant String DEFAULTFILE = "pfc.lng"

Protected:
// The language file in use ("" if none)
string	is_file
// Its entries, sorted by key (keys in lower case)
string	is_keys[]
string	is_values[]
long		il_count
end variables

forward prototypes
public function integer of_setlanguagefile (string as_file)
public function string of_getlanguagefile ()
public function string of_getdefaultlanguagefile ()
public function long of_getcount ()
public function string of_gettext (string as_key, string as_default)
public function string of_gettext (string as_key, string as_default, string as_parms[])
public function boolean of_getentry (string as_key, ref string as_text)
public function integer of_getmessage (string as_id, ref string as_title, ref string as_text)
public function integer of_getmessage (string as_id, ref string as_title, ref string as_text, string as_parms[])
protected function long of_find (string as_key)
protected function string of_unescape (string as_value)
protected function boolean of_hasplaceholders (string as_text)
protected function integer of_load (string as_file)
protected subroutine of_sort (long al_seq[])
protected function string of_getapplicationfolder ()
end prototypes

public function integer of_setlanguagefile (string as_file);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_SetLanguageFile
//
//	Access:  public
//
//	Arguments:
//	as_file		the language file (with its path), or "" to use none
//
//	Returns:  Integer
//	 1 = the file was read
//	 0 = there is no such file (or as_file is ""): texts are left in English
//	-1 = the file could not be read
//
//	Description:  Reads a language file, replacing the entries read before.  By default
//		the service reads lang\pfc.lng in the application folder when it is created.
//		Use this function to choose another file, for example to switch languages.
//
//////////////////////////////////////////////////////////////////////////////
//
//	Revision History
//
//	Version
//	2025	Initial version
//
//////////////////////////////////////////////////////////////////////////////
//
/*
 * Open Source PowerBuilder Foundation Class Libraries
 *
 * Copyright (c) 2004-2017, All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted in accordance with the MIT License

 *
 * https://opensource.org/licenses/MIT
 *
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many
 * individuals and was originally based on software copyright (c)
 * 1996-2004 Sybase, Inc. http://www.sybase.com.  For more
 * information on the Open Source PowerBuilder Foundation Class
 * Libraries see https://github.com/OpenSourcePFCLibraries
*/
//
//////////////////////////////////////////////////////////////////////////////

string	ls_empty[]

is_keys = ls_empty
is_values = ls_empty
il_count = 0
is_file = ""

If IsNull(as_file) Or Len(Trim(as_file)) = 0 Then Return 0
If Not FileExists(as_file) Then Return 0

Return of_Load(as_file)
end function

public function string of_getlanguagefile ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_GetLanguageFile
//
//	Access:  public
//
//	Arguments:  None
//
//	Returns:  String.  The language file in use, or "" if there is none
//
//////////////////////////////////////////////////////////////////////////////
//
//	Revision History
//
//	Version
//	2025	Initial version
//
//////////////////////////////////////////////////////////////////////////////
//
/*
 * Open Source PowerBuilder Foundation Class Libraries
 *
 * Copyright (c) 2004-2017, All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted in accordance with the MIT License

 *
 * https://opensource.org/licenses/MIT
 *
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many
 * individuals and was originally based on software copyright (c)
 * 1996-2004 Sybase, Inc. http://www.sybase.com.  For more
 * information on the Open Source PowerBuilder Foundation Class
 * Libraries see https://github.com/OpenSourcePFCLibraries
*/
//
//////////////////////////////////////////////////////////////////////////////

Return is_file
end function

public function string of_getdefaultlanguagefile ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_GetDefaultLanguageFile
//
//	Access:  public
//
//	Arguments:  None
//
//	Returns:  String.  lang\pfc.lng in the application folder: the folder of the
//		executable, or the current folder when the application runs in the IDE
//
//	Description:  The language file the service reads when it is created.  As with
//		PowerBuilder's own lang\default.lng, replace this file with one for another
//		language to translate the PFC.
//
//////////////////////////////////////////////////////////////////////////////
//
//	Revision History
//
//	Version
//	2025	Initial version
//
//////////////////////////////////////////////////////////////////////////////
//
/*
 * Open Source PowerBuilder Foundation Class Libraries
 *
 * Copyright (c) 2004-2017, All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted in accordance with the MIT License

 *
 * https://opensource.org/licenses/MIT
 *
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many
 * individuals and was originally based on software copyright (c)
 * 1996-2004 Sybase, Inc. http://www.sybase.com.  For more
 * information on the Open Source PowerBuilder Foundation Class
 * Libraries see https://github.com/OpenSourcePFCLibraries
*/
//
//////////////////////////////////////////////////////////////////////////////

Return of_GetApplicationFolder() + "lang\" + DEFAULTFILE
end function

public function long of_getcount ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_GetCount
//
//	Access:  public
//
//	Arguments:  None
//
//	Returns:  Long.  The number of entries in the language file in use
//
//////////////////////////////////////////////////////////////////////////////
//
//	Revision History
//
//	Version
//	2025	Initial version
//
//////////////////////////////////////////////////////////////////////////////
//
/*
 * Open Source PowerBuilder Foundation Class Libraries
 *
 * Copyright (c) 2004-2017, All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted in accordance with the MIT License

 *
 * https://opensource.org/licenses/MIT
 *
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many
 * individuals and was originally based on software copyright (c)
 * 1996-2004 Sybase, Inc. http://www.sybase.com.  For more
 * information on the Open Source PowerBuilder Foundation Class
 * Libraries see https://github.com/OpenSourcePFCLibraries
*/
//
//////////////////////////////////////////////////////////////////////////////

Return il_count
end function

public function string of_gettext (string as_key, string as_default);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_GetText
//
//	Access:  public
//
//	Arguments:
//	as_key		key of the entry in the language file
//	as_default	text to use when the file has no such entry (the English text)
//
//	Returns:  String.  The text from the language file, or as_default
//
//	Description:  For texts that application code builds, for example
//			st_status.Text = gnv_app.inv_language.of_GetText("app_status_ready", "Ready")
//
//////////////////////////////////////////////////////////////////////////////
//
//	Revision History
//
//	Version
//	2025	Initial version
//
//////////////////////////////////////////////////////////////////////////////
//
/*
 * Open Source PowerBuilder Foundation Class Libraries
 *
 * Copyright (c) 2004-2017, All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted in accordance with the MIT License

 *
 * https://opensource.org/licenses/MIT
 *
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many
 * individuals and was originally based on software copyright (c)
 * 1996-2004 Sybase, Inc. http://www.sybase.com.  For more
 * information on the Open Source PowerBuilder Foundation Class
 * Libraries see https://github.com/OpenSourcePFCLibraries
*/
//
//////////////////////////////////////////////////////////////////////////////

string	ls_text

ls_text = as_default
of_GetEntry(as_key, ls_text)
Return ls_text
end function

public function string of_gettext (string as_key, string as_default, string as_parms[]);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_GetText
//
//	Access:  public
//
//	Arguments:
//	as_key		key of the entry in the language file
//	as_default	text to use when the file has no such entry (the English text)
//	as_parms[]	values for the placeholders (%s, or %1 - %9) in the text
//
//	Returns:  String.  The text from the language file, or as_default, with the
//		placeholders replaced (see n_cst_string.of_Format)
//
//////////////////////////////////////////////////////////////////////////////
//
//	Revision History
//
//	Version
//	2025	Initial version
//
//////////////////////////////////////////////////////////////////////////////
//
/*
 * Open Source PowerBuilder Foundation Class Libraries
 *
 * Copyright (c) 2004-2017, All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted in accordance with the MIT License

 *
 * https://opensource.org/licenses/MIT
 *
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many
 * individuals and was originally based on software copyright (c)
 * 1996-2004 Sybase, Inc. http://www.sybase.com.  For more
 * information on the Open Source PowerBuilder Foundation Class
 * Libraries see https://github.com/OpenSourcePFCLibraries
*/
//
//////////////////////////////////////////////////////////////////////////////

n_cst_string	lnv_string

Return lnv_string.of_Format(of_GetText(as_key, as_default), as_parms)
end function

public function boolean of_getentry (string as_key, ref string as_text);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_GetEntry
//
//	Access:  public
//
//	Arguments:
//	as_key		key of the entry in the language file
//	as_text		(by ref) set to the text from the language file, if it has the entry
//
//	Returns:  Boolean.  True if the language file has the entry
//
//////////////////////////////////////////////////////////////////////////////
//
//	Revision History
//
//	Version
//	2025	Initial version
//
//////////////////////////////////////////////////////////////////////////////
//
/*
 * Open Source PowerBuilder Foundation Class Libraries
 *
 * Copyright (c) 2004-2017, All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted in accordance with the MIT License

 *
 * https://opensource.org/licenses/MIT
 *
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many
 * individuals and was originally based on software copyright (c)
 * 1996-2004 Sybase, Inc. http://www.sybase.com.  For more
 * information on the Open Source PowerBuilder Foundation Class
 * Libraries see https://github.com/OpenSourcePFCLibraries
*/
//
//////////////////////////////////////////////////////////////////////////////

long	ll_index

ll_index = of_Find(as_key)
If ll_index = 0 Then Return False

as_text = is_values[ll_index]
Return True
end function

public function integer of_getmessage (string as_id, ref string as_title, ref string as_text);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_GetMessage
//
//	Access:  public
//
//	Arguments:
//	as_id			message ID, as passed to of_MessageBox
//	as_title		(by ref) the title; replaced by the entry <as_id>.title, if any
//	as_text		(by ref) the text; replaced by the entry <as_id>, if any
//
//	Returns:  Integer.  1 if the text was replaced, 0 if not
//
//	Description:  Called by of_MessageBox in the PFC objects.  An entry with
//		placeholders (%s) is not used here: the values are not known.  Messages with
//		values use of_GetMessage(as_id, as_title, as_text, as_parms[]).
//
//////////////////////////////////////////////////////////////////////////////
//
//	Revision History
//
//	Version
//	2025	Initial version
//
//////////////////////////////////////////////////////////////////////////////
//
/*
 * Open Source PowerBuilder Foundation Class Libraries
 *
 * Copyright (c) 2004-2017, All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted in accordance with the MIT License

 *
 * https://opensource.org/licenses/MIT
 *
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many
 * individuals and was originally based on software copyright (c)
 * 1996-2004 Sybase, Inc. http://www.sybase.com.  For more
 * information on the Open Source PowerBuilder Foundation Class
 * Libraries see https://github.com/OpenSourcePFCLibraries
*/
//
//////////////////////////////////////////////////////////////////////////////

string	ls_text
integer	li_rc

If IsNull(as_id) Or Len(as_id) = 0 Then Return 0

of_GetEntry(as_id + ".title", as_title)
If of_GetEntry(as_id, ls_text) Then
	If Not of_HasPlaceholders(ls_text) Then
		as_text = ls_text
		li_rc = 1
	End If
End If

Return li_rc
end function

public function integer of_getmessage (string as_id, ref string as_title, ref string as_text, string as_parms[]);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_GetMessage
//
//	Access:  public
//
//	Arguments:
//	as_id			message ID, as passed to of_MessageBox
//	as_title		(by ref) the title; replaced by the entry <as_id>.title, if any
//	as_text		(by ref) the English text with placeholders (%s); replaced by the entry
//					<as_id>, if any, and then the placeholders by the values
//	as_parms[]	values for the placeholders
//
//	Returns:  Integer.  1 if the text was replaced by the entry, 0 if not
//
//////////////////////////////////////////////////////////////////////////////
//
//	Revision History
//
//	Version
//	2025	Initial version
//
//////////////////////////////////////////////////////////////////////////////
//
/*
 * Open Source PowerBuilder Foundation Class Libraries
 *
 * Copyright (c) 2004-2017, All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted in accordance with the MIT License

 *
 * https://opensource.org/licenses/MIT
 *
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many
 * individuals and was originally based on software copyright (c)
 * 1996-2004 Sybase, Inc. http://www.sybase.com.  For more
 * information on the Open Source PowerBuilder Foundation Class
 * Libraries see https://github.com/OpenSourcePFCLibraries
*/
//
//////////////////////////////////////////////////////////////////////////////

n_cst_string	lnv_string
integer	li_rc

If Not IsNull(as_id) And Len(as_id) > 0 Then
	of_GetEntry(as_id + ".title", as_title)
	If of_GetEntry(as_id, as_text) Then li_rc = 1
End If

as_text = lnv_string.of_Format(as_text, as_parms)
Return li_rc
end function

protected function long of_find (string as_key);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_Find
//
//	Access:  protected
//
//	Arguments:
//	as_key		key (not case sensitive)
//
//	Returns:  Long.  The index of the entry in is_keys / is_values, or 0
//
//////////////////////////////////////////////////////////////////////////////
//
//	Revision History
//
//	Version
//	2025	Initial version
//
//////////////////////////////////////////////////////////////////////////////
//
/*
 * Open Source PowerBuilder Foundation Class Libraries
 *
 * Copyright (c) 2004-2017, All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted in accordance with the MIT License

 *
 * https://opensource.org/licenses/MIT
 *
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many
 * individuals and was originally based on software copyright (c)
 * 1996-2004 Sybase, Inc. http://www.sybase.com.  For more
 * information on the Open Source PowerBuilder Foundation Class
 * Libraries see https://github.com/OpenSourcePFCLibraries
*/
//
//////////////////////////////////////////////////////////////////////////////

long		ll_low, ll_high, ll_mid
string	ls_key

If il_count = 0 Or IsNull(as_key) Then Return 0

ls_key = Lower(as_key)
ll_low = 1
ll_high = il_count
Do While ll_low <= ll_high
	ll_mid = Int((ll_low + ll_high) / 2)
	If is_keys[ll_mid] = ls_key Then Return ll_mid
	If is_keys[ll_mid] < ls_key Then
		ll_low = ll_mid + 1
	Else
		ll_high = ll_mid - 1
	End If
Loop

Return 0
end function

protected function string of_unescape (string as_value);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_Unescape
//
//	Access:  protected
//
//	Arguments:
//	as_value		value as written in the language file
//
//	Returns:  String.  The value with the PowerScript escapes (~r ~n ~t ~" ~' ~~)
//		replaced by the characters
//
//////////////////////////////////////////////////////////////////////////////
//
//	Revision History
//
//	Version
//	2025	Initial version
//
//////////////////////////////////////////////////////////////////////////////
//
/*
 * Open Source PowerBuilder Foundation Class Libraries
 *
 * Copyright (c) 2004-2017, All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted in accordance with the MIT License

 *
 * https://opensource.org/licenses/MIT
 *
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many
 * individuals and was originally based on software copyright (c)
 * 1996-2004 Sybase, Inc. http://www.sybase.com.  For more
 * information on the Open Source PowerBuilder Foundation Class
 * Libraries see https://github.com/OpenSourcePFCLibraries
*/
//
//////////////////////////////////////////////////////////////////////////////

string	ls_result, ls_char
long		ll_pos, ll_start

ll_start = 1
ll_pos = Pos(as_value, "~~")
Do While ll_pos > 0 And ll_pos < Len(as_value)
	Choose Case Mid(as_value, ll_pos + 1, 1)
		Case "r"
			ls_char = "~r"
		Case "n"
			ls_char = "~n"
		Case "t"
			ls_char = "~t"
		Case "~"", "'", "~~"
			ls_char = Mid(as_value, ll_pos + 1, 1)
		Case Else
			// Not an escape: keep the tilde
			ls_char = "~~" + Mid(as_value, ll_pos + 1, 1)
	End Choose
	ls_result += Mid(as_value, ll_start, ll_pos - ll_start) + ls_char
	ll_start = ll_pos + 2
	ll_pos = Pos(as_value, "~~", ll_start)
Loop

Return ls_result + Mid(as_value, ll_start)
end function

protected function boolean of_hasplaceholders (string as_text);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_HasPlaceholders
//
//	Access:  protected
//
//	Arguments:
//	as_text		text
//
//	Returns:  Boolean.  True if the text has a placeholder (%s or %1 - %9)
//
//////////////////////////////////////////////////////////////////////////////
//
//	Revision History
//
//	Version
//	2025	Initial version
//
//////////////////////////////////////////////////////////////////////////////
//
/*
 * Open Source PowerBuilder Foundation Class Libraries
 *
 * Copyright (c) 2004-2017, All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted in accordance with the MIT License

 *
 * https://opensource.org/licenses/MIT
 *
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many
 * individuals and was originally based on software copyright (c)
 * 1996-2004 Sybase, Inc. http://www.sybase.com.  For more
 * information on the Open Source PowerBuilder Foundation Class
 * Libraries see https://github.com/OpenSourcePFCLibraries
*/
//
//////////////////////////////////////////////////////////////////////////////

long	ll_pos

ll_pos = Pos(as_text, "%")
Do While ll_pos > 0
	Choose Case Mid(as_text, ll_pos + 1, 1)
		Case "s", "1", "2", "3", "4", "5", "6", "7", "8", "9"
			Return True
		Case "%"
			ll_pos++
	End Choose
	ll_pos = Pos(as_text, "%", ll_pos + 1)
Loop

Return False
end function

protected function integer of_load (string as_file);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_Load
//
//	Access:  protected
//
//	Arguments:
//	as_file		language file
//
//	Returns:  Integer.  1 if the file was read, -1 if it could not be opened
//
//	Description:  Reads a language file.  The format is the one of PowerBuilder's
//		lang\default.lng: one entry per line, KEY="text", and comment lines that start
//		with #.  Texts can use the PowerScript escapes ~r ~n ~t ~" and ~~.  The file can
//		be UTF-16 (like default.lng), UTF-8 or ANSI; the encoding is read from its byte
//		order mark.  When a key appears more than once, the last entry is used.
//
//////////////////////////////////////////////////////////////////////////////
//
//	Revision History
//
//	Version
//	2025	Initial version
//
//////////////////////////////////////////////////////////////////////////////
//
/*
 * Open Source PowerBuilder Foundation Class Libraries
 *
 * Copyright (c) 2004-2017, All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted in accordance with the MIT License

 *
 * https://opensource.org/licenses/MIT
 *
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many
 * individuals and was originally based on software copyright (c)
 * 1996-2004 Sybase, Inc. http://www.sybase.com.  For more
 * information on the Open Source PowerBuilder Foundation Class
 * Libraries see https://github.com/OpenSourcePFCLibraries
*/
//
//////////////////////////////////////////////////////////////////////////////

integer	li_file
long		ll_read, ll_pos, ll_seq[]
string	ls_line, ls_key, ls_value

li_file = FileOpen(as_file, LineMode!, Read!, Shared!, Append!, FileEncoding(as_file))
If li_file = -1 Then Return -1

ll_read = FileReadEx(li_file, ls_line)
Do While ll_read <> -100 And ll_read <> -1
	ls_line = Trim(ls_line)
	If Len(ls_line) > 0 And Left(ls_line, 1) <> "#" Then
		ll_pos = Pos(ls_line, "=")
		If ll_pos > 1 Then
			ls_key = Lower(Trim(Left(ls_line, ll_pos - 1)))
			ls_value = Trim(Mid(ls_line, ll_pos + 1))
			If Len(ls_value) >= 2 And Left(ls_value, 1) = '"' And Right(ls_value, 1) = '"' Then
				ls_value = Mid(ls_value, 2, Len(ls_value) - 2)
			End If
			il_count++
			is_keys[il_count] = ls_key
			is_values[il_count] = of_Unescape(ls_value)
			ll_seq[il_count] = il_count
		End If
	End If
	ll_read = FileReadEx(li_file, ls_line)
Loop
FileClose(li_file)

of_Sort(ll_seq)
is_file = as_file
Return 1
end function

protected subroutine of_sort (long al_seq[]);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_Sort
//
//	Access:  protected
//
//	Arguments:
//	al_seq[]		order in which the entries were read
//
//	Returns:  None
//
//	Description:  Sorts the entries by key (shell sort), and keeps only the last entry
//		read for a key, so that of_Find can do a binary search.
//
//////////////////////////////////////////////////////////////////////////////
//
//	Revision History
//
//	Version
//	2025	Initial version
//
//////////////////////////////////////////////////////////////////////////////
//
/*
 * Open Source PowerBuilder Foundation Class Libraries
 *
 * Copyright (c) 2004-2017, All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted in accordance with the MIT License

 *
 * https://opensource.org/licenses/MIT
 *
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many
 * individuals and was originally based on software copyright (c)
 * 1996-2004 Sybase, Inc. http://www.sybase.com.  For more
 * information on the Open Source PowerBuilder Foundation Class
 * Libraries see https://github.com/OpenSourcePFCLibraries
*/
//
//////////////////////////////////////////////////////////////////////////////

long		ll_gap, ll_idx, ll_pos, ll_seq, ll_count
string	ls_key, ls_value

// Shell sort on (key, order read)
ll_gap = 1
Do While ll_gap < il_count / 3
	ll_gap = ll_gap * 3 + 1
Loop
Do While ll_gap >= 1
	For ll_idx = ll_gap + 1 To il_count
		ls_key = is_keys[ll_idx]
		ls_value = is_values[ll_idx]
		ll_seq = al_seq[ll_idx]
		ll_pos = ll_idx
		Do While ll_pos > ll_gap
			If is_keys[ll_pos - ll_gap] < ls_key Then Exit
			If is_keys[ll_pos - ll_gap] = ls_key And al_seq[ll_pos - ll_gap] < ll_seq Then Exit
			is_keys[ll_pos] = is_keys[ll_pos - ll_gap]
			is_values[ll_pos] = is_values[ll_pos - ll_gap]
			al_seq[ll_pos] = al_seq[ll_pos - ll_gap]
			ll_pos -= ll_gap
		Loop
		is_keys[ll_pos] = ls_key
		is_values[ll_pos] = ls_value
		al_seq[ll_pos] = ll_seq
	Next
	ll_gap = Int(ll_gap / 3)
Loop

// Keep the last entry read for each key
For ll_idx = 1 To il_count
	If ll_count > 0 Then
		If is_keys[ll_count] = is_keys[ll_idx] Then
			is_values[ll_count] = is_values[ll_idx]
			Continue
		End If
	End If
	ll_count++
	is_keys[ll_count] = is_keys[ll_idx]
	is_values[ll_count] = is_values[ll_idx]
Next
il_count = ll_count
end subroutine

protected function string of_getapplicationfolder ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_GetApplicationFolder
//
//	Access:  protected
//
//	Arguments:  None
//
//	Returns:  String.  The folder of the executable, or the current folder when the
//		application runs in the IDE, with a trailing backslash
//
//////////////////////////////////////////////////////////////////////////////
//
//	Revision History
//
//	Version
//	2025	Initial version
//
//////////////////////////////////////////////////////////////////////////////
//
/*
 * Open Source PowerBuilder Foundation Class Libraries
 *
 * Copyright (c) 2004-2017, All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted in accordance with the MIT License

 *
 * https://opensource.org/licenses/MIT
 *
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many
 * individuals and was originally based on software copyright (c)
 * 1996-2004 Sybase, Inc. http://www.sybase.com.  For more
 * information on the Open Source PowerBuilder Foundation Class
 * Libraries see https://github.com/OpenSourcePFCLibraries
*/
//
//////////////////////////////////////////////////////////////////////////////

string	ls_folder
ulong		lul_len

// In the IDE, Handle(GetApplication()) is 0 and the executable is PowerBuilder itself
If Handle(GetApplication()) <> 0 Then
	ls_folder = Space(1024)
	lul_len = GetModuleFileNameW(0, ls_folder, 1024)
	If lul_len > 0 Then
		ls_folder = Left(ls_folder, lul_len)
		ls_folder = Left(ls_folder, LastPos(ls_folder, "\"))
	Else
		ls_folder = ""
	End If
End If

If ls_folder = "" Then ls_folder = GetCurrentDirectory()
If Right(ls_folder, 1) <> "\" Then ls_folder += "\"
Return ls_folder
end function

on pfc_n_cst_language.create
call super::create
end on

on pfc_n_cst_language.destroy
call super::destroy
end on

event constructor;call super::constructor;//////////////////////////////////////////////////////////////////////////////
//
//	Event:  constructor
//
//	Description:  Reads the default language file, lang\pfc.lng in the application
//		folder, if there is one.
//
//////////////////////////////////////////////////////////////////////////////
//
//	Revision History
//
//	Version
//	2025	Initial version
//
//////////////////////////////////////////////////////////////////////////////
//
/*
 * Open Source PowerBuilder Foundation Class Libraries
 *
 * Copyright (c) 2004-2017, All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted in accordance with the MIT License

 *
 * https://opensource.org/licenses/MIT
 *
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many
 * individuals and was originally based on software copyright (c)
 * 1996-2004 Sybase, Inc. http://www.sybase.com.  For more
 * information on the Open Source PowerBuilder Foundation Class
 * Libraries see https://github.com/OpenSourcePFCLibraries
*/
//
//////////////////////////////////////////////////////////////////////////////

of_SetLanguageFile(of_GetDefaultLanguageFile())
end event
