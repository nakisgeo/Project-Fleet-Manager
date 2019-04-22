#Using System.Windows.Forms
#Using System.Threading
#Using System.Diagnostics

Global ms_frmSplash := null as SplashScreen	// STATIC
Global ms_oThread := null as Thread		   	// STATIC

PARTIAL CLASS SplashScreen INHERIT System.Windows.Forms.Form

Public Static Method ShowForm() as void
	ms_frmSplash := SplashScreen{}
	Application.Run(ms_frmSplash)
Return


// A static method to close the SplashScreen
Public Static Method CloseForm() as void
	if ms_frmSplash == NULL
		Return
	endif
	ms_frmSplash:Close()
	// Process the Close Message on the Splash Thread
	Application.DoEvents()
Return


// Now add a method to create and launch the splash screen on its own thread:
Public Static Method ShowSplashScreen() as void
	// Make sure it is only launched once.
	if ms_frmSplash <> null
		return
	endif
	ms_oThread := Thread{ThreadStart{null, @SplashScreen.ShowForm()}}
	ms_oThread:IsBackground := true
	ms_oThread:ApartmentState := ApartmentState.STA
	ms_oThread:Start()
Return

End Class


PARTIAL CLASS MainForm INHERIT DevExpress.XtraEditors.XtraForm

//#IFNDEF __DEBUG__
METHOD CloseSplashScreen() AS VOID
/*	if ! lSplashScreenClosed
		lSplashScreenClosed := True
		// Close SplashScreen
		ms_frmSplash:Close()
	endif
	//SplashScreen.CloseForm()
	Local processes as Process[]
	if oSoftway:ApplicationActivateOrRun("Communicator", processes)
		//wb(processes[1]:MainWindowTitle, "Is running")
		oSoftway:SetForegroundWindow(NULL, processes[1]:MainWindowTitle)
	endif*/

	if lSplashScreenClosed .or. ms_frmSplash == NULL
		Return
	endif
	lSplashScreenClosed := True

	// Close SplashScreen
	//SplashScreen.CloseFormStatic()
	//ms_frmSplash:CloseForm(ms_frmSplash)
	ms_frmSplash:Close()
	//SplashScreen.CloseForm()
	//ms_oThread:Abort()
	// Process the Close Message on the Splash Thread
	Application.DoEvents()
	//ms_oThread:Join(500)

	LOCAL processes AS Process[]
	if oSoftway:ApplicationActivateOrRun(Application.ProductName, processes)
		//wb(processes[1]:MainWindowTitle, "Is running")
		oSoftway:SetForegroundWindow(NULL, processes[1]:MainWindowTitle)
	endif
	//ms_frmSplash:BeginInvoke(MethodInvoker{null, @SplashScreen.CloseForm()})
	//System.Threading.Thread.Sleep(1000)
	//Application.DoEvents()
Return
//#endif

End Class
