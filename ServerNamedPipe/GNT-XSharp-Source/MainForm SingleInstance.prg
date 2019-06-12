// MainForm_SingleInstance.prg
/*#USING System
#USING System.Windows.Forms
#USING System.Threading
#USING System.Runtime.InteropServices
#USING System.Reflection

PARTIAL CLASS MainForm INHERIT DevExpress.XtraEditors.XtraForm
	EXPORT minimizedToTray AS LOGIC
	EXPORT notifyIcon AS NotifyIcon

PROTECTED VIRTUAL METHOD WndProc(message REF Message) AS VOID
	IF message:Msg == SingleInstance.WM_SHOWFIRSTINSTANCE
		//wb(message:Msg:ToString(), SingleInstance.WM_SHOWFIRSTINSTANCE:ToString())
		SELF:ShowWindow()
	ENDIF
	SUPER:WndProc(message)
RETURN


//private void btnMinToTray_Click(object sender, EventArgs e)
//{
//	// Tie this function to a button on your main form that will minimize your
//	// application to the notification icon area (aka system tray).
//	MinimizeToTray();
//}

//VOID MinimizeToTray()
//{
//	notifyIcon = new NotifyIcon();
//	//notifyIcon.Click += new EventHandler(NotifyIconClick);
//	notifyIcon.DoubleClick += new EventHandler(NotifyIconClick);
//	notifyIcon.Icon = this.Icon;
//	notifyIcon.Text = ProgramInfo.AssemblyTitle;
//	notifyIcon.Visible = TRUE;
//	this.WindowState = FormWindowState.Minimized;
//	this.Hide();
//	minimizedToTray = TRUE;
//}

//void NotifyIconClick(Object sender, System.EventArgs e)
//{
//		SELF:ShowWindow()
//}

PUBLIC METHOD ShowWindow() AS VOID
	DO CASE
	CASE SELF:minimizedToTray
		SELF:notifyIcon:Visible := FALSE
		SELF:Show()
		SELF:WindowState := FormWindowState.Normal
		//SELF:WindowState := FormWindowState.Maximized
		minimizedToTray := FALSE
		//WinApi.SetForegroundWindow(SELF:Handle)

	CASE SELF:WindowState == FormWindowState.Minimized
        WinApi.ShowWindow(SELF:Handle, 9)
        WinApi.SetForegroundWindow(SELF:Handle)

	OTHERWISE
		//WinApi.ShowToFront()
        WinApi.SetForegroundWindow(SELF:Handle)
	ENDCASE
RETURN

END CLASS*/