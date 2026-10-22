//objectcomments Redirect listener with a client socket that plays the browser, for the listener tests
forward
global type n_pfctest_redirectlistener from n_cst_redirectlistener
end type
end forward

global type n_pfctest_redirectlistener from n_cst_redirectlistener
end type
global n_pfctest_redirectlistener n_pfctest_redirectlistener

forward prototypes
public function longptr of_clientconnect ()
public function integer of_clientsend (longptr al_client, string as_text)
public function string of_clientreceive (longptr al_client)
public subroutine of_clientclose (longptr al_client)
end prototypes

public function longptr of_clientconnect ();// Connects to the listener, as a browser would (a blocking socket)
blob{16}	lblb_addr
longptr	ll_client
byte		lbyte_hi, lbyte_lo

ll_client = ws_socket(AF_INET, SOCK_STREAM, IPPROTO_TCP)
If ll_client = INVALID_SOCKET Then Return INVALID_SOCKET
SetByte(lblb_addr, 1, 2)
lbyte_hi = Int(il_port / 256)
lbyte_lo = Mod(il_port, 256)
SetByte(lblb_addr, 3, lbyte_hi)
SetByte(lblb_addr, 4, lbyte_lo)
SetByte(lblb_addr, 5, 127)
SetByte(lblb_addr, 8, 1)
If ws_connect(ll_client, lblb_addr, 16) <> 0 Then
	ws_closesocket(ll_client)
	Return INVALID_SOCKET
End If
Return ll_client
end function

public function integer of_clientsend (longptr al_client, string as_text);blob	lblb_data

lblb_data = Blob(as_text, EncodingUTF8!)
If ws_send(al_client, lblb_data, Len(lblb_data), 0) = Len(lblb_data) Then Return 1
Return -1
end function

public function string of_clientreceive (longptr al_client);// Reads the response until the listener closes the connection (at most 3 seconds)
blob{4096}	lblb_buffer
blob			lblb_data
long			ll_read, ll_end

of_SetNonBlocking(al_client)
ll_end = CPU() + 3000
Do While CPU() < ll_end
	ll_read = ws_recv(al_client, lblb_buffer, 4096, 0)
	If ll_read > 0 Then
		lblb_data += BlobMid(lblb_buffer, 1, ll_read)
	ElseIf ll_read = 0 Then
		Exit
	ElseIf ws_WSAGetLastError() = WSAEWOULDBLOCK Then
		ws_Sleep(10)
	Else
		Exit
	End If
Loop
Return String(lblb_data, EncodingUTF8!)
end function

public subroutine of_clientclose (longptr al_client);ws_closesocket(al_client)
end subroutine

on n_pfctest_redirectlistener.create
call super::create
end on

on n_pfctest_redirectlistener.destroy
call super::destroy
end on
